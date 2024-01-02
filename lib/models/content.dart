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
        double? aspectRatio;
        double? widthPercent;
        if (json['width'] == null || json['height'] == null) {
          aspectRatio = null;
        } else if (json['width'] is String) {
          if (json['width'].contains('%')) {
            String percent = json['width'].replaceAll('%', '');
            widthPercent = double.parse(percent) / 100;
          }
          if (widthPercent == null) {
            aspectRatio =
                double.parse(json['width']) / double.parse(json['height']);
          } else {
            double width = double.parse(json['height']) * widthPercent;
            aspectRatio = width / double.parse(json['height']);
          }
        } else {
          aspectRatio = json['width'] / json['height'];
        }
        return Content(
          data: json['embeddedCode'],
          aspectRatio: aspectRatio,
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
      } else if (BaseModel.checkJsonKeys(json, ['resized'])) {
        return Content(
          data: json['resized']['w800'],
          aspectRatio: null,
          description: json['desc'],
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
