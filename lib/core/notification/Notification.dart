import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/testt');

  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestSoundPermission: true,
    requestAlertPermission: true,
    requestBadgePermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(String title, String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('notification'), // File âm thanh
    icon: '@mipmap/testt', // Thay smallIcon bằng icon
  );

  const DarwinNotificationDetails darwinPlatformChannelSpecifics =
  DarwinNotificationDetails(
    sound: 'notification.mp3', // Chỉ dùng tên file
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // ID thông báo
    title,
    message,
    platformChannelSpecifics,
  );
}