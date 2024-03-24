import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static late SharedPreferences _prefs;

  static Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;
  static Duration receiveTimeout = const Duration(milliseconds: 3000);
  static Duration connectTimeout = const Duration(milliseconds: 2000);
}
