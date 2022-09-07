import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class TimelineCollectionPick extends CollectionPick {
  final NewsListItem news;

  TimelineCollectionPick({
    required String id,
    required this.news,
    required int customYear,
    int? customMonth,
    int? customDay,
    DateTime? customTime,
    int sortOrder = 0,
    Member? creator,
    String? summary,
  }) : super(
          id: id,
          sortOrder: sortOrder,
          creator: creator,
          pickNewsId: news.id,
          customYear: customYear,
          customMonth: customMonth,
          customDay: customDay,
          customTime: customTime,
          newsListItem: news,
          summary: summary,
        );

  factory TimelineCollectionPick.fromCollectionPickWithNewsListItem(
      CollectionPick collectionPick) {
    return TimelineCollectionPick(
      id: collectionPick.id,
      news: collectionPick.newsListItem!,
      customYear: collectionPick.newsListItem!.publishedDate.year,
      customMonth: collectionPick.newsListItem!.publishedDate.month,
      customDay: collectionPick.newsListItem!.publishedDate.day,
      sortOrder: collectionPick.sortOrder,
      creator: collectionPick.creator,
    );
  }

  factory TimelineCollectionPick.fromJson(Map<String, dynamic> json) {
    DateTime? time;
    if (json['custom_time'] != null) {
      time = DateTime.tryParse(json['custom_time'])?.toLocal();
    }

    String? summary = json['summary'];
    if (summary?.isEmpty ?? false) {
      summary = null;
    }

    return TimelineCollectionPick(
      sortOrder: json['sort_order'],
      id: json['id'],
      news: NewsListItem.fromJson(json['story']),
      creator: Member.fromJson(json['creator']),
      customYear: json['custom_year'],
      customMonth: json['custom_month'],
      customDay: json['custom_day'],
      customTime: time,
      summary: summary,
    );
  }
}
