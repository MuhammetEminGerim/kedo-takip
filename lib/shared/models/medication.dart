import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 6)
class Medication extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String catId;

  @HiveField(2, defaultValue: '')
  String name;

  @HiveField(3, defaultValue: '')
  String dosage;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5, defaultValue: null)
  DateTime? endDate;

  @HiveField(6, defaultValue: null)
  String? frequency; // e.g. "Every 12 hours"

  @HiveField(7, defaultValue: null)
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
