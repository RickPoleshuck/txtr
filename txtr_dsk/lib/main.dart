import 'package:flutter/material.dart';
import 'package:txtr_dsk/src/globals.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.initSharedPreferences();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    title: 'TXTR Desktop',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });
  runApp(const App());
}
