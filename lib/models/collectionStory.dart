import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/publisher.dart';

class CollectionStory {
  int? order;
  final String id;
  final String title;
  final Publisher source;
  final DateTime publishedDate;
  final String url;
  final String? heroImageUrl;
  final List<PickKind>? pickKinds;

  CollectionStory({
    this.order,
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    required this.publishedDate,
    this.heroImageUrl,
    this.pickKinds,
  });

  factory CollectionStory.fromJson(Map<String, dynamic> json) {
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

    int? order;

    return CollectionStory(
      order: order,
      id: json['id'],
      title: json['title'],
      source: Publisher.fromJson(json['source']),
      url: json['url'],
      heroImageUrl: json['og_image'],
      publishedDate: DateTime.parse(json["published_date"]).toLocal(),
      pickKinds: pickKinds,
    );
  }
}
