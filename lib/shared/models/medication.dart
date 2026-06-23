import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 6)
class Medication extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String catId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String dosage;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  @HiveField(6)
  String? frequency; // e.g. "Every 12 hours"

  @HiveField(7)
  String? notes;

  Medication({
    required this.id,
    required this.catId,
    required this.name,
    required this.dosage,
    required this.startDate,
    this.endDate,
    this.frequency,
    this.notes,
  });
}
