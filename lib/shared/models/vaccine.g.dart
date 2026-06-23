// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineAdapter extends TypeAdapter<Vaccine> {
  @override
  final int typeId = 4;

  @override
  Vaccine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vaccine(
      id: fields[0] as String,
      catId: fields[1] as String,
      name: fields[2] as String,
      dateAdministered: fields[3] as DateTime,
      nextDueDate: fields[4] as DateTime?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Vaccine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dateAdministered)
      ..writeByte(4)
      ..write(obj.nextDueDate)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
