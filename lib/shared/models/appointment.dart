import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 5)
class Appointment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String catId;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? clinicName;

  @HiveField(5)
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
