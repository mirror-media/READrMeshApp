import 'package:readr/models/contentList.dart';

class Paragraph {
  String? styles;
  String? type;
  ContentList? contents;

  Paragraph({
    this.styles,
    this.type,
    this.contents,
  });

  factory Paragraph.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Paragraph();
    }

    ContentList contents;
    contents = ContentList.fromJson(json["content"]);

    return Paragraph(
      type: json['type'],
      contents: contents,
    );
  }
}
