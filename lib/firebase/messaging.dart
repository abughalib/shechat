import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Messaging {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initializeMessaging() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) => {debugPrint('payload: $payload')});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("onMessage: $message");
      await handleMessage(message);
    });
  }

  static handleMessage(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('CHAT', "CHAT",
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0,
        "New Messages",
        message.data['sender'] + ": " + message.data['message'],
        platformChannelSpecifics,
        payload: 'CHAT');
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
