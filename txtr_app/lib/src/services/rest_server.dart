import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:network_info_plus/network_info_plus.dart';
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

class RestServer {
  final ContactService _contactService = ContactService();
  static const idTokenKey = 'idToken';
  static const loginKey = 'login';
  static const passwdKey = 'passwd';
  static final DateTime _epoch = DateTime(1970);
  DateTime _lastMessageUpdate = _epoch;
  final Router _router = Router();
  SecurityContext? _securityContext;
  HttpServer? _httpServer;

  Future<void> start() async {
    _router.get('/api/messages', _getMessages);
    _router.get('/api/contacts', _getContacts);
    _router.post('/api/login', _postLogin);
    _router.get('/api/phone', _getPhone);
    _router.get('/api/updates', _getUpdates);
    _router.post('/api/message', _postMessage);
    _contactService.refresh();
    debugPrint('IP=${await NetworkInfo().getWifiIP() ?? ''}');
    _securityContext = await _getSecurityContext();
    final SettingsModel settings = await SettingsService.load();
    _httpServer = await io.serve(_router, InternetAddress.anyIPv4, settings.port,
        securityContext: _securityContext);
    debugPrint(
        'Starting listening for ReST requests: ${_httpServer!.address}:${_httpServer!.port}');
  }

  Future<void> restart() async {
    if (_httpServer != null) {
      _httpServer!.close(force: true);
    }
    start();
  }

  Future<bool> _checkToken(final Request request) async {
    final String? paramToken = request.url.queryParameters['idToken'];
    if (paramToken == null) {
      return false;
    }
    final idToken = await PreferenceService().get(idTokenKey);
    return paramToken == idToken;
  }

  static final RestServer _singleton = RestServer._internal();

  factory RestServer() {
    return _singleton;
  }

  RestServer._internal();

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
      final String result = _messageToJson(messages);
      _lastMessageUpdate = DateTime.now();
      return Response.ok(result);
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  }

  String _normalizePhoneNumber(final String number) {
    // @TODO - allow other country codes other than +1
    if (RegExp(r'^\d{10}$').hasMatch(number)) {
      return '+1$number';
    }
    return number;
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
    final SettingsModel settings = await PreferenceService().getSettings();
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
    final ip = await NetworkInfo().getWifiIP() ?? '';
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
    final String result = await Sms().send(message);

    return Response.ok(result);
  }

  String _messageToJson(final List<SmsMessage> messages) {
    final List<TxtrMessageDTO> messagesDto = [];
    for (final SmsMessage m in messages) {
      final phone = _normalizePhoneNumber(m.address!);
      String name = _contactService.getNameByPhoneNumber(phone ?? 'unknown');
      messagesDto.add(TxtrMessageDTO(m.id!, name, _normalizePhoneNumber(phone),
          m.date!, m.body ?? '', m.read!, m.kind == SmsMessageKind.sent));
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
