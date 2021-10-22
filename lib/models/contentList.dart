import 'dart:convert';

import 'package:readr/models/content.dart';
import 'package:readr/models/customizedList.dart';

class ContentList extends CustomizedList<Content> {
  // constructor
  ContentList();

  factory ContentList.fromJson(List<dynamic> parsedJson) {
    ContentList contents = ContentList();

    List parseList = List.empty(growable: true);
    for (int i = 0; i < parsedJson.length; i++) {
      parseList.add(Content.fromJson(parsedJson[i]));
    }

    for (var element in parseList) {
      contents.add(element);
    }

    return contents;
  }

  factory ContentList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return ContentList.fromJson(jsonData);
  }
}
