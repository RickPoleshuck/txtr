import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:txtr_dsk/src/globals.dart';
import 'package:txtr_dsk/src/services/net_service.dart';
import 'package:txtr_dsk/src/views/settings/bloc/settings_model.dart';

class SettingsService {
  static const String settingsKey = 'settings';
  static const String tokenKey = 'idToken';

  static Future<void> save(final SettingsModel settings) async {
    debugPrint('SettingsService.save($settings)');
    await Globals.prefs.setString(settingsKey, jsonEncode(settings.toJson()));
    final idToken =
        await NetService().login(settings.login, settings.passwd);
    await Globals.prefs.setString(tokenKey, idToken);
  }

  static SettingsModel load() {
    debugPrint('SettingsService.load()');
    final rawSettings = Globals.prefs.getString(settingsKey);
    return rawSettings == null
        ? SettingsModel.empty()
        : SettingsModel.fromJson(jsonDecode(rawSettings));
  }

  static String? get idToken => Globals.prefs.getString(tokenKey);
}
