import 'dart:convert';

import 'package:readr/models/content.dart';

class Paragraph {
  String? styles;
  String? type;
  List<Content>? contents;

  Paragraph({
    this.styles,
    this.type,
    this.contents,
  });

  factory Paragraph.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Paragraph();
    }

    List<Content> contents;
    contents = List<Content>.from(
        json["content"].map((content) => Content.fromJson(content)));

    return Paragraph(
      type: json['type'],
      contents: contents,
    );
  }

  static List<Paragraph> parseResponseBody(String body) {
    try {
      final jsonData = json.decode(body);
      if (jsonData == "" || jsonData == null) {
        return [];
      }

      return parseListFromJson(jsonData);
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static List<Paragraph> parseListFromJson(List<dynamic> parsedJson) {
    return List<Paragraph>.from(parsedJson.map((e) => Paragraph.fromJson(e)));
  }
}
