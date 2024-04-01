import 'package:permission_handler/permission_handler.dart';
class PermissionService {
  final needed = [
    Permission.sms,
    Permission.contacts,
  ];

  Future<bool> requestAll() async {
    for (Permission need in needed) {
      if ((await need.request()).isDenied) return false;
    }
    return true;
  }
}