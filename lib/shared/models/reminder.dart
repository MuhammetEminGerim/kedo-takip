import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 8)
class Reminder extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String catId;

  @HiveField(2, defaultValue: '')
  String catName;

  @HiveField(3, defaultValue: 'meal')
  String type; // 'meal', 'medication', 'appointment'

  @HiveField(4, defaultValue: '')
  String title;

  @HiveField(5, defaultValue: 8)
  int hour;

  @HiveField(6, defaultValue: 0)
  int minute;

  @HiveField(7, defaultValue: true)
  bool isEnabled;

  @HiveField(8, defaultValue: 0)
  int notificationId;

  @HiveField(9, defaultValue: null)
  String? linkedId; // linked medication/appointment id

  @HiveField(10, defaultValue: null)
  DateTime? specificDate; // for one-time reminders (appointments)

  Reminder({
    required this.id,
    required this.catId,
    required this.catName,
    required this.type,
    required this.title,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.notificationId = 0,
    this.linkedId,
    this.specificDate,
  });

  bool get isRecurring => type == 'meal' || type == 'medication';
}
