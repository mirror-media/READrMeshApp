import 'package:hive/hive.dart';

part 'communityListItemType.g.dart';

@HiveType(typeId: 4)
enum CommunityListItemType {
  @HiveField(0)
  pickStory,

  @HiveField(1)
  pickCollection,

  @HiveField(2)
  commentStory,

  @HiveField(3)
  commentCollection,

  @HiveField(4)
  createCollection,

  @HiveField(5)
  updateCollection,
}
