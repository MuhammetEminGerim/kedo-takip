import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/reminder.dart';
import '../../../core/services/notification_service.dart';

final reminderBoxProvider = Provider<Box<Reminder>>((ref) {
  throw UnimplementedError('reminderBox is not initialized');
});

final reminderListProvider = NotifierProvider<ReminderListNotifier, List<Reminder>>(ReminderListNotifier.new);

class ReminderListNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    final box = ref.watch(reminderBoxProvider);
    return box.values.toList();
  }

  /// Get reminders for a specific cat
  List<Reminder> remindersForCat(String catId) {
    return state.where((r) => r.catId == catId).toList();
  }

  /// Get reminders by type
  List<Reminder> remindersByType(String type) {
    return state.where((r) => r.type == type).toList();
  }

  /// Add a new reminder
  Future<void> addReminder({
    required String catId,
    required String catName,
    required String type,
    required String title,
    required int hour,
    required int minute,
    String? linkedId,
    DateTime? specificDate,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final reminder = Reminder(
      id: const Uuid().v4(),
      catId: catId,
      catName: catName,
      type: type,
      title: title,
      hour: hour,
      minute: minute,
      isEnabled: true,
      notificationId: notificationId,
      linkedId: linkedId,
      specificDate: specificDate,
    );

    final box = ref.read(reminderBoxProvider);
    await box.put(reminder.id, reminder);
    state = box.values.toList();

    // Schedule the notification
    await _scheduleNotification(reminder);
  }

  /// Toggle a reminder on/off
  Future<void> toggleReminder(String reminderId) async {
    final box = ref.read(reminderBoxProvider);
    final reminder = box.get(reminderId);
    if (reminder == null) return;

    reminder.isEnabled = !reminder.isEnabled;
    await reminder.save();
    state = box.values.toList();

    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    } else {
      await NotificationService.instance.cancelNotification(reminder.notificationId);
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime(String reminderId, int hour, int minute) async {
    final box = ref.read(reminderBoxProvider);
    final reminder = box.get(reminderId);
    if (reminder == null) return;

    // Cancel old notification
    await NotificationService.instance.cancelNotification(reminder.notificationId);

    reminder.hour = hour;
    reminder.minute = minute;
    await reminder.save();
    state = box.values.toList();

    // Reschedule
    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    }
  }

  /// Update reminder full details
  Future<void> updateReminderDetails(String reminderId, {
    required String title,
    required String catId,
    required String catName,
    required int hour,
    required int minute,
  }) async {
    final box = ref.read(reminderBoxProvider);
    final reminder = box.get(reminderId);
    if (reminder == null) return;

    await NotificationService.instance.cancelNotification(reminder.notificationId);

    reminder.title = title;
    reminder.catId = catId;
    reminder.catName = catName;
    reminder.hour = hour;
    reminder.minute = minute;
    
    await reminder.save();
    state = box.values.toList();

    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    }
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    final box = ref.read(reminderBoxProvider);
    final reminder = box.get(reminderId);
    if (reminder == null) return;

    await NotificationService.instance.cancelNotification(reminder.notificationId);
    await box.delete(reminderId);
    state = box.values.toList();
  }

  /// Delete all reminders for a specific linked entity (medication/appointment)
  Future<void> deleteRemindersForLinkedId(String linkedId) async {
    final box = ref.read(reminderBoxProvider);
    final toDelete = state.where((r) => r.linkedId == linkedId).toList();
    for (final reminder in toDelete) {
      await NotificationService.instance.cancelNotification(reminder.notificationId);
      await box.delete(reminder.id);
    }
    state = box.values.toList();
  }

  /// Schedule notification based on reminder type
  Future<void> _scheduleNotification(Reminder reminder) async {
    final ns = NotificationService.instance;

    if (reminder.isRecurring) {
      // Daily recurring (meal/medication)
      await ns.scheduleDailyReminder(
        notificationId: reminder.notificationId,
        title: _getNotificationTitle(reminder),
        body: _getNotificationBody(reminder),
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } else if (reminder.specificDate != null) {
      // One-time (appointment)
      await ns.scheduleOneTimeReminder(
        notificationId: reminder.notificationId,
        title: _getNotificationTitle(reminder),
        body: _getNotificationBody(reminder),
        scheduledDateTime: reminder.specificDate!,
      );
    }
  }

  String _getNotificationTitle(Reminder reminder) {
    switch (reminder.type) {
      case 'meal':
        return '🍽️ Mama Zamanı!';
      case 'medication':
        return '💊 İlaç Zamanı!';
      case 'appointment':
        return '📅 Randevu Hatırlatması';
      default:
        return '🐾 PawLog Hatırlatıcı';
    }
  }

  String _getNotificationBody(Reminder reminder) {
    switch (reminder.type) {
      case 'meal':
        return '${reminder.catName} mamaya ihtiyaç duyuyor! 🐱';
      case 'medication':
        return '${reminder.catName} — ${reminder.title}';
      case 'appointment':
        return '${reminder.catName}: ${reminder.title}';
      default:
        return reminder.title;
    }
  }

  /// Re-schedule all enabled reminders (e.g., after app restart)
  Future<void> rescheduleAllReminders() async {
    for (final reminder in state) {
      if (reminder.isEnabled) {
        await _scheduleNotification(reminder);
      }
    }
  }
}
