import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static late SharedPreferences _prefs;

  static Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;
}
