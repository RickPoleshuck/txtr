class PhoneDTO {
  final String ip;
  final String name;
  final String device;

  PhoneDTO(this.ip, this.name, this.device);

  PhoneDTO.fromJson(Map<String, dynamic> json)
      : ip = json['ip'],
        name = json['name'],
        device = json['device'];

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'name': name,
        'device': device,
      };
  PhoneDTO.empty() :
    ip = '127.0.0.1',
    name = 'None',
    device = 'None';
}
