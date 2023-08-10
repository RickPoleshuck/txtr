import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:txtr_app/src/services/contact_service.dart';
import 'package:txtr_app/src/services/preference_service.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';
import 'package:txtr_app/src/settings/bloc/settings_service.dart';
import 'package:txtr_app/src/sms.dart';
import 'package:txtr_shared/txtr_shared.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class RestServer {
  final ContactService _contactService = ContactService();
  static const idTokenKey = 'idToken';
  static const loginKey = 'login';
  static const passwdKey = 'passwd';
  static const String settingsKey = 'settings';
  static final DateTime _epoch = DateTime(1970);
  DateTime _lastMessageUpdate = _epoch;

  Future<void> start() async {
    final Router app = Router();
    app.get('/api/messages', _getMessages);
    app.get('/api/contacts', _getContacts);
    app.post('/api/login', _postLogin);
    app.get('/api/phone', _getPhone);
    app.get('/api/updates', _getUpdates);
    app.post('/api/message', _postMessage);
    _contactService.refresh();
    final securityContext = await _getSecurityContext();
    await io.serve(app, InternetAddress.anyIPv4, TxtrShared.restPort,
        securityContext: securityContext);
  }

  Future<bool> _checkToken(final Request request) async {
    final String? paramToken = request.url.queryParameters['idToken'];
    if (paramToken == null) {
      return false;
    }
    final idToken = await PreferenceService().get(idTokenKey);
    return paramToken == idToken;
  }

  Future<Response> _getMessages(final Request request) async {
    debugPrint('_getMessages');
    final validToken = await _checkToken(request);
    if (!validToken) {
      return Response.unauthorized('Invalid idToken');
    }
    try {
      List<SmsMessage> messages = await Sms().query(
          count: 100); // @TODO - Maximum of 100 inbox and 100 sent messages
      List<TxtrMessageDTO> messageDTOs = [];
      for (final SmsMessage m in messages) {
        messageDTOs.add(TxtrMessageDTO(m.id!, m.sender!, m.address!, m.date!,
            m.body ?? '', m.read!, m.kind == SmsMessageKind.sent));
      }
      final String result = _messageToJson(messages);
      _lastMessageUpdate = DateTime.now();
      return Response.ok(result);
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Future<Response> _getUpdates(final Request request) async {
    debugPrint('_getUpdates');
    final validToken = await _checkToken(request);
    if (!validToken) {
      return Response.unauthorized('Invalid idToken');
    }
    try {
      List<SmsMessage> messages = await Sms().query(count: 1);
      final DateTime latestMessageTime =
          messages.isEmpty ? _epoch : messages[0].date!;
      var updateType = 'none';
      if (latestMessageTime.compareTo(_lastMessageUpdate) > 0) {
        updateType = 'messages';
      }
      return Response.ok(updateType);
    } catch (e) {
      debugPrint('Error: $e');
      return Response.badRequest(body: e.toString());
    }
  }

  Future<Response> _getContacts(final Request request) async {
    debugPrint('_getContacts');
    final validToken = await _checkToken(request);
    if (!validToken) {
      return Response.unauthorized('Invalid idToken');
    }
    final String? lastUpdateStr = request.url.queryParameters['lastUpdate'];
    final lastUpdate =
        lastUpdateStr == null ? _epoch : DateTime.parse(lastUpdateStr);
    try {
      if (lastUpdate.isBefore(ContactService().lastUpdate)) {
        ContactService().refresh();
        return Response.ok(_contactToJson(ContactService().allContacts));
      } else {
        // nothing new to return
        return Response.ok([]);
      }
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  Future<Response> _getPhone(final Request request) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final String? rawSettings = await PreferenceService().get(settingsKey);
    final SettingsModel settings = rawSettings == null
        ? SettingsModel.empty()
        : SettingsModel.fromJson(jsonDecode(rawSettings));
    final phoneName = settings.phoneName;

    late String model;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.model;
    } else {
      return Response.badRequest(body: 'Not a phone');
    }
    final ip = await WifiInfo().getWifiIP() ?? '';
    PhoneDTO phoneDTO = PhoneDTO(ip, phoneName, model);
    return Response.ok(jsonEncode(phoneDTO));
  }

  Future<Response> _postLogin(final Request request) async {
    debugPrint('_postLogin');
    final String query = await request.readAsString();
    Map queryParams = jsonDecode(query);
    final SettingsModel settings = await SettingsService.load();

    if (settings.login == queryParams['login'] &&
        settings.passwd == queryParams['passwd']) {
      String? token = await PreferenceService().get(idTokenKey);
      if (token == null) {
        token = const Uuid().v4();
        PreferenceService().put(idTokenKey, token);
      }
      return Response.ok(token);
    } else {
      return Response.badRequest(body: 'bad');
    }
  }

  Future<Response> _postMessage(final Request request) async {
    debugPrint('_postMessage');
    final validToken = await _checkToken(request);
    if (!validToken) {
      return Response.unauthorized('Invalid idToken');
    }
    final String query = await request.readAsString();
    Map<String, dynamic> queryParams = jsonDecode(query);
    final TxtrMessageDTO message = TxtrMessageDTO.fromJson(queryParams);
    Sms().send(message);

    return Response.ok(null);
  }

  String _messageToJson(final List<SmsMessage> messages) {
    final List<TxtrMessageDTO> messagesDto = [];
    for (final SmsMessage m in messages) {
      String name =
          _contactService.getNameByPhoneNumber(m.address ?? 'unknown');
      messagesDto.add(TxtrMessageDTO(m.id!, name, m.address!, m.date!,
          m.body ?? '', m.read!, m.kind == SmsMessageKind.sent));
    }
    return jsonEncode(messagesDto);
  }

  String _contactToJson(final List<Contact> contacts) {
    final List<TxtrContactDTO> contactsDto = [];
    for (final Contact c in contacts) {
      List<TxtrPhoneDTO> phonesDTO = [];
      for (Phone p in c.phones) {
        String label = switch (p.label) {
          PhoneLabel.custom => p.customLabel,
          _ => p.label.name
        };
        phonesDTO.add(TxtrPhoneDTO(p.normalizedNumber, label, p.isPrimary));
      }
      contactsDto.add(TxtrContactDTO(c.id, c.displayName, phonesDTO));
    }
    return jsonEncode(contactsDto);
  }

  Future<SecurityContext> _getSecurityContext() async {
    final certBytes = await rootBundle.load('assets/ssl/cert.pem');
    final keyBytes = await rootBundle.load('assets/ssl/key.pem');
    return SecurityContext()
      ..useCertificateChainBytes(certBytes.buffer.asInt8List())
      ..usePrivateKeyBytes(keyBytes.buffer.asInt8List());
  }
}
