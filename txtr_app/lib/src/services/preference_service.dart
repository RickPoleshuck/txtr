import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';

class PreferenceService {
  static final PreferenceService _singleton = PreferenceService._internal();
  static Database? _database;

  factory PreferenceService() {
    return _singleton;
  }

  PreferenceService._internal() {}

  Future<Database> get _db async {
    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> put(final String key, final String value) async {
    final db = await _db;
    db.execute('''
      insert into preference (key, value) values (?,?)
      on conflict(key) do update set value=?;
    ''', [key, value, value]);
  }

  Future<String?> get(final String key) async {
    final db = await _db;
    final rs = db.select('''
      select value from preference where key = ?
    ''', [key]);
    if (rs.isEmpty) return null;
    return rs.rows[0][0].toString();
  }

  Future<SettingsModel> getSettings() async {
    String? rawSettings = await get('settings');
    return rawSettings == null
        ? SettingsModel.empty()
        : SettingsModel.fromJson(jsonDecode(rawSettings));
  }

  Future<void> putSettings(final SettingsModel settings) async {

  }
  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/prefs.db';

    final db = sqlite3.open(path);
    db.execute('''
      create table if not exists preference (
        key text primary key,
        value text
      ) without rowid
    ''');
    return db;
  }
}
