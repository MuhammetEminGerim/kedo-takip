// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 8;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String? ?? '',
      catId: fields[1] as String? ?? '',
      catName: fields[2] as String? ?? '',
      type: fields[3] as String? ?? 'meal',
      title: fields[4] as String? ?? '',
      hour: fields[5] as int? ?? 8,
      minute: fields[6] as int? ?? 0,
      isEnabled: fields[7] as bool? ?? true,
      notificationId: fields[8] as int? ?? 0,
      linkedId: fields[9] as String?,
      specificDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.catName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.hour)
      ..writeByte(6)
      ..write(obj.minute)
      ..writeByte(7)
      ..write(obj.isEnabled)
      ..writeByte(8)
      ..write(obj.notificationId)
      ..writeByte(9)
      ..write(obj.linkedId)
      ..writeByte(10)
      ..write(obj.specificDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
