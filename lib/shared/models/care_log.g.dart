// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareLogAdapter extends TypeAdapter<CareLog> {
  @override
  final int typeId = 2;

  @override
  CareLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareLog(
      id: fields[0] as String,
      catId: fields[1] as String,
      type: fields[2] as String,
      timestamp: fields[3] as DateTime,
      value: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CareLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
