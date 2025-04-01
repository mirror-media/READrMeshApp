// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communityListItemType.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunityListItemTypeAdapter extends TypeAdapter<CommunityListItemType> {
  @override
  final int typeId = 4;

  @override
  CommunityListItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CommunityListItemType.pickStory;
      case 1:
        return CommunityListItemType.pickCollection;
      case 2:
        return CommunityListItemType.commentStory;
      case 3:
        return CommunityListItemType.commentCollection;
      case 4:
        return CommunityListItemType.createCollection;
      case 5:
        return CommunityListItemType.updateCollection;
      default:
        return CommunityListItemType.pickStory;
    }
  }

  @override
  void write(BinaryWriter writer, CommunityListItemType obj) {
    switch (obj) {
      case CommunityListItemType.pickStory:
        writer.writeByte(0);
        break;
      case CommunityListItemType.pickCollection:
        writer.writeByte(1);
        break;
      case CommunityListItemType.commentStory:
        writer.writeByte(2);
        break;
      case CommunityListItemType.commentCollection:
        writer.writeByte(3);
        break;
      case CommunityListItemType.createCollection:
        writer.writeByte(4);
        break;
      case CommunityListItemType.updateCollection:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityListItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
