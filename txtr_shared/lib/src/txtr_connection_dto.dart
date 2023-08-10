class TxtrConnectionDTO {
  final String ip;

  TxtrConnectionDTO(this.ip);

  TxtrConnectionDTO.fromJson(Map<String, dynamic> json)
      : ip = json['ip'];

  Map<String, dynamic> toJson() => {
    'ip': ip,
  };
}
