import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Request post notification permission for Android 13+
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  static Future<void> scheduleReminder({
    required String bookId,
    required String bookName,
    required double dueAmount,
    required String interval,
  }) async {
    final int id = bookId.hashCode & 0x7FFFFFFF;

    RepeatInterval repeatInterval;
    if (interval == 'daily') {
      repeatInterval = RepeatInterval.daily;
    } else if (interval == 'weekly') {
      repeatInterval = RepeatInterval.weekly;
    } else {
      await cancelReminder(bookId);
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'due_reminders',
          'Due Book Reminders',
          channelDescription:
              'Reminders for due books in Transaction Record App',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.periodicallyShow(
      id: id,
      title: 'Due Reminder: $bookName',
      body: 'Pending amount to collect: ₹${dueAmount.toStringAsFixed(0)}',
      repeatInterval: repeatInterval,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelReminder(String bookId) async {
    final int id = bookId.hashCode & 0x7FFFFFFF;
    await _notificationsPlugin.cancel(id: id);
  }
}
