// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotifyAdapter extends TypeAdapter<Notify> {
  @override
  final int typeId = 2;

  @override
  Notify read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notify(
      id: fields[0] as String,
      sender: fields[1] as Member,
      type: fields[2] as NotifyType,
      objectId: fields[3] as String,
      actionTime: fields[4] as DateTime,
      isRead: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Notify obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.objectId)
      ..writeByte(4)
      ..write(obj.actionTime)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotifyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
