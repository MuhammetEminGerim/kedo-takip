import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      // Provide basic linux/windows settings if available to prevent errors,
      // but wrapping in try-catch is safer for unsupported platforms.
    );

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request Android 13+ notification permissions
      if (Platform.isAndroid) {
        final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
        await androidImplementation?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('🔔 Notification initialization failed (expected on Windows/Linux): $e');
    }

    _isInitialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
  }

  /// Schedule a daily recurring notification (for meals, medications)
  Future<void> scheduleDailyReminder({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pawlog_daily_reminders',
          'Günlük Hatırlatıcılar',
          channelDescription: 'Mama ve ilaç hatırlatıcıları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
      payload: 'daily_$notificationId',
    );

    debugPrint('🔔 Daily reminder scheduled: $title at $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Schedule a one-time notification (for appointments)
  Future<void> scheduleOneTimeReminder({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      debugPrint('🔔 Skipping past notification: $title');
      return;
    }

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pawlog_appointments',
          'Randevu Hatırlatıcıları',
          channelDescription: 'Veteriner randevu hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'appointment_$notificationId',
    );

    debugPrint('🔔 One-time reminder scheduled: $title at $scheduledDateTime');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
    debugPrint('🔔 Notification cancelled: $notificationId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('🔔 All notifications cancelled');
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    await _plugin.show(
      99999,
      '🐾 PawLog Bildirim Testi',
      'Bildirimler çalışıyor! 🎉',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pawlog_test',
          'Test Bildirimleri',
          channelDescription: 'Test bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }
}
