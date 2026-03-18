import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/settings_screen.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future init() async {

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await notifications.initialize(settings: settings);

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future showNotification() async {

    /// nếu tắt notification thì không hiện
    if (!SettingsScreen.notification) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      "pomodoro_channel",
      "Pomodoro",
      importance: Importance.max,
      priority: Priority.high,

      /// SOUND CONTROL
      playSound: SettingsScreen.sound,

      /// VIBRATION CONTROL
      enableVibration: SettingsScreen.vibration,
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notifications.show(
      id: 0,
      title: "Pomodoro Finished",
      body: "Time to take a break!",
      notificationDetails: details,
    );
  }

}