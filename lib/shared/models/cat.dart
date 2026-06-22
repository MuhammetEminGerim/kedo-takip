import 'package:hive/hive.dart';

part 'cat.g.dart';

@HiveType(typeId: 0)
class Cat extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String breed;

  @HiveField(3)
  DateTime birthDate;

  @HiveField(4)
  bool isNeutered;

  @HiveField(5)
  String gender;

  @HiveField(6)
  double? weight;

  @HiveField(7)
  String? photoPath;

  Cat({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    this.isNeutered = false,
    required this.gender,
    this.weight,
    this.photoPath,
  });
}
