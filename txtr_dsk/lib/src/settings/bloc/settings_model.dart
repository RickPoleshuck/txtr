class SettingsModel {
  final String login;
  final String passwd;
  final String theme;
  late String phoneIp;
  late String phoneName;
  final String idToken;

  SettingsModel(this.login, this.passwd, this.theme, this.phoneIp,
      this.phoneName, this.idToken);

  SettingsModel.fromJson(Map<String, dynamic> json)
      : login = json['login'],
        passwd = json['passwd'],
        theme = json['theme'] ?? '',
        phoneIp = json['phoneIp'] ?? '',
        phoneName = json['phoneName'] ?? '',
        idToken = json['idToken'] ?? '';

  Map<String, dynamic> toJson() => {
        'login': login,
        'passwd': passwd,
        'theme': theme,
        'phoneIp': phoneIp,
        'phoneName': phoneName,
        'idToken': idToken,
      };

  SettingsModel.empty()
      : login = '',
        passwd = '',
        theme = '',
        phoneIp = '',
        phoneName = '',
        idToken = '';
}
