// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataConstants.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotifyTypeAdapter extends TypeAdapter<NotifyType> {
  @override
  final int typeId = 3;

  @override
  NotifyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotifyType.comment;
      case 1:
        return NotifyType.follow;
      case 2:
        return NotifyType.like;
      case 3:
        return NotifyType.pickCollection;
      case 4:
        return NotifyType.commentCollection;
      case 5:
        return NotifyType.createCollection;
      default:
        return NotifyType.comment;
    }
  }

  @override
  void write(BinaryWriter writer, NotifyType obj) {
    switch (obj) {
      case NotifyType.comment:
        writer.writeByte(0);
        break;
      case NotifyType.follow:
        writer.writeByte(1);
        break;
      case NotifyType.like:
        writer.writeByte(2);
        break;
      case NotifyType.pickCollection:
        writer.writeByte(3);
        break;
      case NotifyType.commentCollection:
        writer.writeByte(4);
        break;
      case NotifyType.createCollection:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotifyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
