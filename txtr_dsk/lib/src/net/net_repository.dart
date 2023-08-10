import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_service.dart';
import 'package:txtr_shared/txtr_shared.dart';

class NetRepository {
  final Dio _dio;

  NetRepository() : _dio = Dio() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
  }

  Future<String> getUpdates() async {
    final SettingsModel settings = SettingsService.load();
    final String url =
        'https://${settings.phoneIp}:${TxtrShared.restPort}/api/updates';
    Response response = await _dio
        .get(url, queryParameters: {'idToken': SettingsService.idToken});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<List<TxtrContactDTO>> getContacts(final DateTime lastUpdate) async {
    final SettingsModel settings = SettingsService.load();
    final String url =
        'https://${settings.phoneIp}:${TxtrShared.restPort}/api/contacts';
    Response response = await _dio.get(url, queryParameters: {
      'idToken': SettingsService.idToken,
      'lastUpdate': lastUpdate
    });
    if (response.statusCode == 200) {
      try {
        final List<TxtrContactDTO> contacts = List<TxtrContactDTO>.from(
            jsonDecode(response.data).map((o) => TxtrContactDTO.fromJson(o)));
        return contacts;
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<List<List<TxtrMessageDTO>>> getMessages() async {
    final SettingsModel settings = SettingsService.load();
    final String url =
        'https://${settings.phoneIp}:${TxtrShared.restPort}/api/messages';
    Response response = await _dio
        .get(url, queryParameters: {'idToken': SettingsService.idToken});
    if (response.statusCode == 200) {
      final messages = jsonDecode(response.data)
          .map((o) => TxtrMessageDTO.fromJson(o))
          .toList();
      messages.sort();
      final LinkedHashMap<String, List<TxtrMessageDTO>> contactList =
          LinkedHashMap<String, List<TxtrMessageDTO>>();

      for (final m in messages) {
        List<TxtrMessageDTO>? messagesByContact = contactList[m.address];
        if (messagesByContact == null) {
          messagesByContact = [];
          contactList[m.address] = messagesByContact;
        }
        messagesByContact.add(m);
      }
      final List<List<TxtrMessageDTO>> result = [];
      contactList.forEach((key, value) {
        result.add(value);
      });
      return result;
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<PhoneDTO> getPhone(final String host) async {
    if (host.isEmpty) {
      throw Exception('No phone ip');
    }
    final String url = 'https://$host:${TxtrShared.restPort}/api/phone';
    Response response = await _dio.get(url);
    if (response.statusCode == 200) {
      return PhoneDTO.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<String> login(final String login, final String passwd) async {
    final SettingsModel settings = SettingsService.load();
    final String url =
        'https://${settings.phoneIp}:${TxtrShared.restPort}/api/login';
    Response response =
        await _dio.post(url, data: {'login': login, 'passwd': passwd});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<void> postMessage(final TxtrMessageDTO message) async {
    final SettingsModel settings = SettingsService.load();
    final String url =
        'https://${settings.phoneIp}:${TxtrShared.restPort}/api/message';
    Response response = await _dio.post(url,
        data: jsonEncode(message),
        queryParameters: {'idToken': SettingsService.idToken});
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.statusMessage);
    }
  }
}
