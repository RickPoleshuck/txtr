import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  static final ContactService _singleton = ContactService._internal();
  DateTime _lastUpdated = DateTime(1970);

  factory ContactService() {
    return _singleton;
  }

  ContactService._internal() {
    FlutterContacts.addListener(() {
      _lastUpdated = DateTime.now();
    });
  }

  List<Contact> get allContacts => _allContacts;

  List<Contact> _allContacts = [];
  final Map<String, Contact> _contactMap = {};

  String getNameByPhoneNumber(final String phoneNumber) {
    if (_contactMap.containsKey(phoneNumber)) {
      return _contactMap[phoneNumber]!.displayName;
    }
    for (final Contact c in _allContacts) {
      for (final Phone p in c.phones) {
        if (p.normalizedNumber == phoneNumber) {
          _contactMap[phoneNumber] = c;
          _contactMap.remove(phoneNumber);
          return c.displayName;
        }
      }
    }
    return phoneNumber;
  }

  DateTime get lastUpdate => _lastUpdated;
  /// Only return 'mobile' phones and contacts that have at least one
  Future<void> refresh() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      _allContacts = contacts
          .map((c) => _filterMobile(c))
          .where((c) => c.phones.isNotEmpty)
          .toList();
    } else {
      throw Exception('requestPermission');
    }
  }

  Contact _filterMobile(final Contact contact) {
    contact.phones =
        contact.phones.where((p) => p.label == PhoneLabel.mobile).toList();
    return contact;
  }
}
