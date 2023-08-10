import 'dart:convert';

class TxtrPhoneDTO {
  String number;
  String label;
  bool isPrimary;

  TxtrPhoneDTO(this.number, this.label, this.isPrimary);

  TxtrPhoneDTO.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        label = json['label'],
        isPrimary = json['isPrimary'] ?? false;

  static List<TxtrPhoneDTO> fromJsonAsList(final List<dynamic> json) {
    return json.map((item) => TxtrPhoneDTO.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'label': label,
    'isPrimary': isPrimary,
  };
}

class TxtrContactDTO {
  String id;
  String name;
  List<TxtrPhoneDTO> phones;

  TxtrContactDTO(this.id, this.name, this.phones);

  TxtrContactDTO.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        phones = List<TxtrPhoneDTO>.from(jsonDecode((json['phones'] ?? [])).map((p) => TxtrPhoneDTO.fromJson(p)));


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phones': jsonEncode(phones),
  };
}
