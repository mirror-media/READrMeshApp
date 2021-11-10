import 'package:readr/models/baseModel.dart';

class Content {
  String data;
  double? aspectRatio;
  String? description;

  Content({
    required this.data,
    required this.aspectRatio,
    required this.description,
  });

  factory Content.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (BaseModel.checkJsonKeys(json, ['tablet'])) {
        return Content(
          data: json['tablet']['url'],
          aspectRatio: json['tablet']['width'] / json['tablet']['height'],
          description: json['title'],
        );
      } else if (BaseModel.checkJsonKeys(json, ['youtubeId'])) {
        return Content(
          data: json['youtubeId'],
          aspectRatio: null,
          description: json['description'],
        );
      }
      // audio or video
      else if (BaseModel.checkJsonKeys(json, ['url'])) {
        return Content(
          data: json['url'],
          aspectRatio: null,
          description: json['name'],
        );
      } else if (BaseModel.checkJsonKeys(json, ['embeddedCode'])) {
        return Content(
          data: json['embeddedCode'],
          aspectRatio: (json['width'] == null || json['height'] == null)
              ? null
              : double.parse(json['width']) / double.parse(json['height']),
          description: json['caption'],
        );
      } else if (BaseModel.checkJsonKeys(json, ['draftRawObj']) ||
          BaseModel.checkJsonKeys(json, ['title'])) {
        return Content(
          data: json['body'],
          aspectRatio: null,
          description: json['title'],
        );
      } else if (BaseModel.checkJsonKeys(json, ['quote'])) {
        return Content(
          data: json['quote'],
          aspectRatio: null,
          description: json['quoteBy'],
        );
      }
    }

    return Content(
      data: json.toString(),
      aspectRatio: null,
      description: null,
    );
  }
}
