import 'dart:convert';

import 'package:txtr_dsk/src/globals.dart';
import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';

class SettingsService {
  static const String settingsKey = 'settings';
  static const String tokenKey = 'idToken';

  static Future<void> save(final SettingsModel settings) async {
    await Globals.prefs.setString(settingsKey, jsonEncode(settings.toJson()));
    final idToken =
        await NetRepository().login(settings.login, settings.passwd);
    await Globals.prefs.setString(tokenKey, idToken);
  }

  static SettingsModel load() {
    final rawSettings = Globals.prefs.getString(settingsKey);
    return rawSettings == null
        ? SettingsModel.empty()
        : SettingsModel.fromJson(jsonDecode(rawSettings));
  }

  static String? get idToken => Globals.prefs.getString(tokenKey);
}
