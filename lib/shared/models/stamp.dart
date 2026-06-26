import 'package:hive/hive.dart';

part 'stamp.g.dart';

@HiveType(typeId: 7)
class Stamp extends HiveObject {
  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String catId;

  @HiveField(2, defaultValue: '')
  final String imagePath;

  @HiveField(3, defaultValue: '')
  final String caption;

  @HiveField(4)
  final DateTime date;

  Stamp({
    required this.id,
    required this.catId,
    required this.imagePath,
    required this.caption,
    required this.date,
  });

  Stamp copyWith({
    String? id,
    String? catId,
    String? imagePath,
    String? caption,
    DateTime? date,
  }) {
    return Stamp(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      date: date ?? this.date,
    );
  }
}
