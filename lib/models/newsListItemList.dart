import 'package:readr/models/customizedList.dart';
import 'package:readr/models/newsListItem.dart';

class NewsListItemList extends CustomizedList<NewsListItem> {
  int allStoryCount = 0;

  NewsListItemList();

  factory NewsListItemList.fromJson(List<dynamic> parsedJson) {
    NewsListItemList newsListItemList = NewsListItemList();
    List parseList = parsedJson.map((i) => NewsListItem.fromJson(i)).toList();
    for (var element in parseList) {
      newsListItemList.add(element);
    }

    return newsListItemList;
  }
}
