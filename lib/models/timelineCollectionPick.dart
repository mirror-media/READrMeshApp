import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class TimelineCollectionPick extends CollectionPick {
  final NewsListItem news;
  int year;
  int? month;
  int? day;
  DateTime? time;

  TimelineCollectionPick({
    required String id,
    required this.news,
    required this.year,
    this.month,
    this.day,
    this.time,
    int sortOrder = 0,
    Member? creator,
  }) : super(
          id: id,
          sortOrder: sortOrder,
          creator: creator,
          pickNewsId: news.id,
          customYear: year,
          customMonth: month,
          customDay: day,
          customTime: time,
          newsListItem: news,
        );

  factory TimelineCollectionPick.fromCollectionPick(
      CollectionPick collectionPick) {
    return TimelineCollectionPick(
      id: collectionPick.id,
      news: collectionPick.newsListItem!,
      year: collectionPick.newsListItem!.publishedDate.year,
      month: collectionPick.newsListItem!.publishedDate.month,
      day: collectionPick.newsListItem!.publishedDate.day,
      sortOrder: collectionPick.sortOrder,
      creator: collectionPick.creator,
    );
  }

  factory TimelineCollectionPick.fromJson(Map<String, dynamic> json) {
    DateTime? time;
    if (json['custom_time'] != null) {
      time = DateTime.tryParse(json['custom_time'])?.toLocal();
    }
    return TimelineCollectionPick(
      sortOrder: json['sort_order'],
      id: json['id'],
      news: NewsListItem.fromJson(json['story']),
      creator: Member.fromJson(json['creator']),
      year: json['custom_year'],
      month: json['custom_month'],
      day: json['custom_day'],
      time: time,
    );
  }
}
