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
}
