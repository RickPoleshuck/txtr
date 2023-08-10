class SettingsModel {
  final String login;
  final String passwd;
  final String theme;
  final String phoneName;

  SettingsModel(this.login, this.passwd, this.theme, this.phoneName);

  SettingsModel.fromJson(Map<String, dynamic> json)
      : login = json['login'],
        passwd = json['passwd'],
        theme = json['theme'] ?? '',
        phoneName = json['phoneName'] ?? '';

  Map<String, dynamic> toJson() => {
        'login': login,
        'passwd': passwd,
        'theme': theme,
        'phoneName': phoneName,
      };

  SettingsModel.empty()
      : login = '',
        passwd = '',
        theme = '',
        phoneName = '';
}
