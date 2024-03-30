import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:txtr_app/src/services/preference_service.dart';
import 'package:txtr_app/src/services/rest_server.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';

class SettingsService {

  static const String settingsKey = 'settings';

  static Future<void> save(final SettingsModel settings) async {
    final SettingsModel previous = await load();
    if (previous.port != settings.port) {
      RestServer().restart();
    }
    await savePref(settingsKey, jsonEncode(settings.toJson()));
  }

  static Future<void> saveLogin(final SettingsModel settings) async {
    await saveLoginPref(settings.login, settings.passwd);
  }
  static Future<SettingsModel> load() async {
    final rawSettings = await loadPref(settingsKey);
    final settings = rawSettings == null || rawSettings.isEmpty
        ? SettingsModel.empty()
        : SettingsModel.fromJson(jsonDecode(rawSettings));
    return settings;
  }

  static Future<void> savePref(final String key, final String value) async {
    await PreferenceService().put(key, value);
  }

  static Future<void> saveLoginPref(final String login, final String passwd) async {
    await PreferenceService().put('login', login);
    await PreferenceService().put('passwd', passwd);
  }

  static Future<String?> loadPref(final String key) async {
    final value = await PreferenceService().get(key);
    return value;
  }

  static Dio getDio() {
    final dio = Dio();
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
    return dio;
  }
}
