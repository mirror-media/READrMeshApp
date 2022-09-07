// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 0;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Member(
      memberId: fields[0] as String,
      nickname: fields[1] as String,
      avatar: fields[2] as String?,
      followingPublisher: (fields[3] as List).cast<Publisher>(),
      following: (fields[4] as List).cast<Member>(),
      customId: fields[5] as String,
      avatarImageId: fields[6] as String?,
      blockMemberIds: (fields[7] as List?)?.cast<String>(),
      blockedMemberIds: (fields[8] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.memberId)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.followingPublisher)
      ..writeByte(4)
      ..write(obj.following)
      ..writeByte(5)
      ..write(obj.customId)
      ..writeByte(6)
      ..write(obj.avatarImageId)
      ..writeByte(7)
      ..write(obj.blockMemberIds)
      ..writeByte(8)
      ..write(obj.blockedMemberIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
