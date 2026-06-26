import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 5)
class Appointment extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String catId;

  @HiveField(2, defaultValue: '')
  String title;

  @HiveField(3)
  DateTime date;

  @HiveField(4, defaultValue: null)
  String? clinicName;

  @HiveField(5, defaultValue: null)
  String? notes;

  Appointment({
    required this.id,
    required this.catId,
    required this.title,
    required this.date,
    this.clinicName,
    this.notes,
  });
}
