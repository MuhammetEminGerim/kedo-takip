import 'package:hive/hive.dart';

part 'stamp.g.dart';

@HiveType(typeId: 7)
class Stamp extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String catId;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
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
