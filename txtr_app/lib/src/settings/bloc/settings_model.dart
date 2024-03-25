import 'package:txtr_shared/txtr_shared.dart';

class SettingsModel {
  final String login;
  final String passwd;
  final String theme;
  final String phoneName;
  final int port;

  SettingsModel(this.login, this.passwd, this.theme, this.phoneName, this.port);

  SettingsModel.fromJson(Map<String, dynamic> json)
      : login = json['login'],
        passwd = json['passwd'],
        theme = json['theme'] ?? '',
        phoneName = json['phoneName'] ?? '',
        port = json['port'] ?? TxtrShared.defRestPort;

  SettingsModel.fromFormJson(Map<String, dynamic> json)
      : login = json['login'],
        passwd = json['passwd'],
        theme = json['theme'] ?? '',
        phoneName = json['phoneName'] ?? '',
        port = int.parse(json['port']);

  Map<String, dynamic> toJson() => {
        'login': login,
        'passwd': passwd,
        'theme': theme,
        'phoneName': phoneName,
        'port': port,
      };

  SettingsModel.empty()
      : login = '',
        passwd = '',
        theme = '',
        phoneName = '',
        port = TxtrShared.defRestPort;
}
