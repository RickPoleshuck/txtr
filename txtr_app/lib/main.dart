import 'package:flutter/material.dart';
import 'package:txtr_app/src/services/background_service.dart';
import 'package:txtr_app/src/services/permission.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService().init();
  await PermissionService().requestAll();
  runApp(const App());
}
