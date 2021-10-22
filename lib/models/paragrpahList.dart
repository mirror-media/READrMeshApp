import 'dart:convert';

import 'package:readr/models/customizedList.dart';
import 'package:readr/models/paragraph.dart';

class ParagraphList extends CustomizedList<Paragraph> {
  // constructor
  ParagraphList();

  factory ParagraphList.fromJson(List<dynamic> parsedJson) {
    ParagraphList paragraphs = ParagraphList();
    List parseList = parsedJson.map((i) => Paragraph.fromJson(i)).toList();
    for (var element in parseList) {
      paragraphs.add(element);
    }

    return paragraphs;
  }

  factory ParagraphList.parseResponseBody(String body) {
    try {
      final jsonData = json.decode(body);
      if (jsonData == "" || jsonData == null) {
        return ParagraphList();
      }

      return ParagraphList.fromJson(jsonData);
    } catch (e) {
      return ParagraphList();
    }
  }
}
