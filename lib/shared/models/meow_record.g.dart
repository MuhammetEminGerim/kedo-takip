// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meow_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeowRecordAdapter extends TypeAdapter<MeowRecord> {
  @override
  final int typeId = 1;

  @override
  MeowRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeowRecord(
      id: fields[0] as String,
      catId: fields[1] as String,
      filePath: fields[2] as String,
      durationSeconds: fields[3] as int,
      timestamp: fields[4] as DateTime,
      contextTag: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MeowRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.contextTag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeowRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
