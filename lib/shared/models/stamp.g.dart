// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stamp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StampAdapter extends TypeAdapter<Stamp> {
  @override
  final int typeId = 7;

  @override
  Stamp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Stamp(
      id: fields[0] == null ? '' : fields[0] as String,
      catId: fields[1] == null ? '' : fields[1] as String,
      imagePath: fields[2] == null ? '' : fields[2] as String,
      caption: fields[3] == null ? '' : fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Stamp obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.caption)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StampAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
