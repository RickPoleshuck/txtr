import 'package:flutter/material.dart';
import 'package:txtr_app/src/services/background_service.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService().init();
  runApp(const App());
}
