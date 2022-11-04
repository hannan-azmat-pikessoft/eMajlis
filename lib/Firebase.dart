import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initialize(context) {
    final InitializationSettings i = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    flutterLocalNotificationsPlugin.initialize(i,
        onSelectNotification: (String route) async {
      if (route != null) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  static void display(m) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              "eMajlis", "eMajlis channel", "this is our channel",
              importance: Importance.max,
              priority: Priority.high,
              color: Colors.black,
              channelShowBadge: true,
              fullScreenIntent: true,
              icon: '@mipmap/ic_launcher',
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              ledColor: Colors.red,
              playSound: true));
      await flutterLocalNotificationsPlugin.show(
        id,
        m['notification']['title'],
        m['notification']['body'],
        notificationDetails,
        payload: m.data["click_action"],
      );
    } catch (e) {
      print(e);
    }
  }
}
