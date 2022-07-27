import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class CollectionStory {
  int sortOrder;
  final String id;
  final DateTime pickedDate;
  final NewsListItem news;
  final Member? creator;

  CollectionStory({
    this.sortOrder = 0,
    required this.id,
    required this.pickedDate,
    required this.news,
    this.creator,
  });

  factory CollectionStory.fromPick(Map<String, dynamic> json) {
    return CollectionStory(
      id: '-1',
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
      news: NewsListItem.fromJson(json['story'], updateController: false),
    );
  }

  factory CollectionStory.fromJson(Map<String, dynamic> json) {
    return CollectionStory(
      sortOrder: json['sort_order'],
      id: json['id'],
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
      news: NewsListItem.fromJson(json['story']),
      creator: Member.fromJson(json['creator']),
    );
  }

  factory CollectionStory.fromNewsListItem(NewsListItem news) {
    return CollectionStory(
      id: '-1',
      pickedDate: DateTime.now(),
      news: news,
    );
  }
}
