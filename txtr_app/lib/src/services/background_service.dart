import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:txtr_app/src/globals.dart';
import 'package:txtr_app/src/services/rest_server.dart';

@pragma('vm:entry-point')
dynamic listen(final ServiceInstance serviceInstance) async {
  await RestServer().start();
  debugPrint('Started listening for ReST requests');
}

class BackgroundService {
  Future<void> init() async {
    final service = FlutterBackgroundService();
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      Globals.notificationChannelId,
      'TXTR Service',
      description: 'This channel is used to report attached clients.',
      // description
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: listen,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: Globals.notificationChannelId,
          initialNotificationTitle: 'TXTR Service',
          initialNotificationContent: 'Listening',
          foregroundServiceNotificationId: Globals.notificationId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: listen,
          onBackground: onIosBackground,
        ));
  }
  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
