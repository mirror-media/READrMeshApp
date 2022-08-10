import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/newsListItem.dart';

class FolderCollectionPick extends CollectionPick {
  final NewsListItem news;

  FolderCollectionPick({
    int sortOrder = 0,
    required String id,
    required this.news,
  }) : super(
          id: id,
          pickNewsId: news.id,
          sortOrder: sortOrder,
          newsListItem: news,
          customYear: news.publishedDate.year,
          customMonth: news.publishedDate.month,
          customDay: news.publishedDate.day,
        );

  factory FolderCollectionPick.fromJson(Map<String, dynamic> json) {
    return FolderCollectionPick(
      sortOrder: json['sort_order'],
      id: json['id'],
      news: NewsListItem.fromJson(json['story']),
    );
  }

  factory FolderCollectionPick.fromCollectionPick(
      CollectionPick collectionPick) {
    return FolderCollectionPick(
      id: collectionPick.id,
      news: collectionPick.newsListItem!,
      sortOrder: collectionPick.sortOrder,
    );
  }
}
