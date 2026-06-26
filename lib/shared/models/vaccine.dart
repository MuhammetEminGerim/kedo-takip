import 'package:hive/hive.dart';

part 'vaccine.g.dart';

@HiveType(typeId: 4)
class Vaccine extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String catId;

  @HiveField(2, defaultValue: '')
  String name;

  @HiveField(3)
  DateTime dateAdministered;

  @HiveField(4, defaultValue: null)
  DateTime? nextDueDate;

  @HiveField(5, defaultValue: null)
  String? notes;

  Vaccine({
    required this.id,
    required this.catId,
    required this.name,
    required this.dateAdministered,
    this.nextDueDate,
    this.notes,
  });
}
