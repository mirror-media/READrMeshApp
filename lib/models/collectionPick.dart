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
    );
  }
}
