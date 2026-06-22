import 'package:hive/hive.dart';

part 'meow_record.g.dart';

@HiveType(typeId: 1)
class MeowRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String catId;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  int durationSeconds;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String contextTag; // 'Before meal', 'After play', etc.

  MeowRecord({
    required this.id,
    required this.catId,
    required this.filePath,
    required this.durationSeconds,
    required this.timestamp,
    required this.contextTag,
  });
}
