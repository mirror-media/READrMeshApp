import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class CollectionPick {
  int sortOrder;
  final String id;
  final String pickNewsId;
  int? customYear;
  int? customMonth;
  int? customDay;
  DateTime? customTime;
  final Member? creator;
  final DateTime? pickedDate;
  final NewsListItem? newsListItem;

  CollectionPick({
    required this.id,
    this.sortOrder = 0,
    required this.pickNewsId,
    this.customYear,
    this.customMonth,
    this.customDay,
    this.customTime,
    this.creator,
    this.pickedDate,
    this.newsListItem,
  });

  factory CollectionPick.fromPick(Map<String, dynamic> json) {
    NewsListItem news = NewsListItem.fromJson(json['story']);
    return CollectionPick(
      id: '-1',
      newsListItem: news,
      pickNewsId: news.id,
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
    );
  }

  factory CollectionPick.fromNewsListItem(NewsListItem news) {
    return CollectionPick(
      id: '-1',
      newsListItem: news,
      pickNewsId: news.id,
      customYear: news.publishedDate.year,
      customMonth: news.publishedDate.month,
      customDay: news.publishedDate.day,
    );
  }

  factory CollectionPick.fromAddToCollection(Map<String, dynamic> json) {
    DateTime? customTime;
    if (json['custom_time'] != null) {
      customTime = DateTime.parse(json['custom_time']);
    }

    return CollectionPick(
      id: json["id"],
      pickNewsId: json["story"]['id'],
      sortOrder: json["sort_order"],
      customYear: json["custom_year"],
      customMonth: json["custom_month"],
      customDay: json["custom_day"],
      customTime: customTime,
    );
  }
}
