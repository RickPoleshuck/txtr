class TxtrMessageDTO extends Comparable  {
  final int id;
  final String name;
  final String address;
  final DateTime date;
  final String body;

  final bool read;
  final bool sent;

  TxtrMessageDTO(this.id, this.name, this.address, this.date, this.body, this.read, this.sent);

  TxtrMessageDTO.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        name = json['name'],
        address = json['address'],
        date = json['date'] == null ? DateTime.now() : DateTime.parse(json['date']),
        body = json['body'] ?? '',
        read = json['read'] ?? false,
        sent = json['sent'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'date': date.toIso8601String(),
        'body': body,
        'read': read,
        'sent': sent,
      };

  @override
  String toString() {
    return 'TxtrMessageDTO{id: $id, name: $name, address: $address, date: $date, body: $body, read: $read, sent: $sent}';
  }

  TxtrMessageDTO.empty() :
        id = -1,
        name = '',
        address = '',
        date = DateTime.now(),
        body =  '',
        read = false,
        sent = false;

  @override
  int compareTo(other) {
    return other.date.compareTo(this.date) ;
  }
}
