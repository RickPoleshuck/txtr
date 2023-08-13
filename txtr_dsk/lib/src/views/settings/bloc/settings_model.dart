import 'dart:convert';

import 'package:txtr_shared/txtr_shared.dart';

class SettingsModel {
  final String login;
  final String passwd;
  PhoneDTO phone;
  final String idToken;

  SettingsModel(this.login, this.passwd, this.phone, this.idToken);

  SettingsModel.fromJson(Map<String, dynamic> json)
      : login = json['login'],
        passwd = json['passwd'],
        phone = json['phone'] != null
            ? PhoneDTO.fromJson(jsonDecode(json['phone']))
            : PhoneDTO.empty(),
        idToken = json['idToken'] ?? '';

  Map<String, dynamic> toJson() => {
        'login': login,
        'passwd': passwd,
        'phone': jsonEncode(phone),
        'idToken': idToken,
      };

  SettingsModel.empty()
      : login = '',
        passwd = '',
        phone = PhoneDTO.empty(),
        idToken = '';
}
