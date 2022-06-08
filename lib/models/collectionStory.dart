import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class CollectionStory {
  int sortOrder;
  final String id;
  final DateTime pickedDate;
  final List<PickKind>? pickKinds;
  final NewsListItem? news;
  final Member? creator;

  CollectionStory({
    this.sortOrder = 0,
    required this.id,
    required this.pickedDate,
    this.pickKinds,
    this.news,
    this.creator,
  });

  factory CollectionStory.fromStory(Map<String, dynamic> json) {
    List<PickKind>? pickKinds;
    if (BaseModel.checkJsonKeys(json, ['pick'])) {
      pickKinds = [];
      for (var pick in json['pick']) {
        if (pick['kind'] == 'read' && !pickKinds.contains(PickKind.read)) {
          pickKinds.add(PickKind.read);
        } else if (pick['kind'] == 'bookmark' &&
            !pickKinds.contains(PickKind.bookmark)) {
          pickKinds.add(PickKind.bookmark);
        }
      }
    }

    return CollectionStory(
      id: '-1',
      pickedDate: DateTime.now(),
      pickKinds: pickKinds,
      news: NewsListItem.fromJson(json),
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
}
