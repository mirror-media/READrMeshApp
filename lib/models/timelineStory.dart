import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class TimelineStory extends CollectionStory {
  int year;
  int? month;
  int? day;
  DateTime? time;

  TimelineStory({
    required String id,
    required DateTime pickedDate,
    required NewsListItem news,
    required this.year,
    this.month,
    this.day,
    this.time,
    int sortOrder = 0,
    Member? creator,
  }) : super(
          id: id,
          pickedDate: pickedDate,
          news: news,
          sortOrder: sortOrder,
          creator: creator,
        );

  factory TimelineStory.fromCollectionStory(CollectionStory collectionStory) {
    return TimelineStory(
      id: collectionStory.id,
      pickedDate: collectionStory.pickedDate,
      news: collectionStory.news,
      year: collectionStory.news.publishedDate.year,
      month: collectionStory.news.publishedDate.month,
      day: collectionStory.news.publishedDate.day,
      sortOrder: collectionStory.sortOrder,
      creator: collectionStory.creator,
    );
  }

  factory TimelineStory.fromJson(Map<String, dynamic> json) {
    return TimelineStory(
      sortOrder: json['sort_order'],
      id: json['id'],
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
      news: NewsListItem.fromJson(json['story']),
      creator: Member.fromJson(json['creator']),
      year: json['custom_year'],
      month: json['custom_month'],
      day: json['custom_day'],
      time: DateTime.tryParse(json['custom_time'] ?? '')?.toLocal(),
    );
  }
}
