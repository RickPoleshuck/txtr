import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_shared/txtr_shared.dart';

class ContactService {
  List<TxtrContactDTO> _contacts = [];
  static final DateTime _epoch =
      DateTime(1969); // client epoch should be before server epoch
  DateTime _lastUpdate = _epoch;
  final NetRepository _netRepository = NetRepository();
  static final ContactService _singleton = ContactService._internal();

  factory ContactService() {
    return _singleton;
  }

  Future<List<TxtrContactDTO>> contacts() async {
    DateTime now = DateTime.now();
    final newContacts = await _netRepository.getContacts(_lastUpdate);
    if (newContacts.isNotEmpty) {
      _contacts = newContacts;
      _lastUpdate = now;
    }

    return _contacts;
  }

  ContactService._internal();
}
