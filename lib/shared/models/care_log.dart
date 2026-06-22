import 'package:hive/hive.dart';

part 'care_log.g.dart';

@HiveType(typeId: 2)
class CareLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String catId;

  @HiveField(2)
  String type; // 'food', 'water', 'litter', 'mood', 'weight'

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? value; // 'Happy', '4.2', 'Refilled' vs.

  CareLog({
    required this.id,
    required this.catId,
    required this.type,
    required this.timestamp,
    this.value,
  });
}
