import 'package:hive/hive.dart';

part 'vaccine.g.dart';

@HiveType(typeId: 4)
class Vaccine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String catId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime dateAdministered;

  @HiveField(4)
  DateTime? nextDueDate;

  @HiveField(5)
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
