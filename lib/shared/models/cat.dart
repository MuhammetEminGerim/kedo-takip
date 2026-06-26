import 'package:hive/hive.dart';

part 'cat.g.dart';

@HiveType(typeId: 0)
class Cat extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String name;

  @HiveField(2, defaultValue: '')
  String breed;

  @HiveField(3)
  DateTime birthDate;

  @HiveField(4, defaultValue: false)
  bool isNeutered;

  @HiveField(5, defaultValue: 'Unknown')
  String gender;

  @HiveField(6, defaultValue: null)
  double? weight;

  @HiveField(7, defaultValue: null)
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
