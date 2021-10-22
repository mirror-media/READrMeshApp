import 'dart:convert';

import 'package:readr/models/customizedList.dart';
import 'package:readr/models/tag.dart';

class TagList extends CustomizedList<Tag> {
  // constructor
  TagList();

  factory TagList.fromJson(List<dynamic> parsedJson) {
    TagList tags = TagList();
    List parseList = parsedJson.map((i) => Tag.fromJson(i)).toList();
    for (var element in parseList) {
      tags.add(element);
    }

    return tags;
  }

  factory TagList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return TagList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> tagMaps = List.empty(growable: true);

    for (Tag tag in this) {
      tagMaps.add(tag.toJson());
    }
    return tagMaps;
  }

  String toJsonString() {
    List<Map> tagMaps = List.empty(growable: true);

    for (Tag tag in this) {
      tagMaps.add(tag.toJson());
    }
    return json.encode(tagMaps);
  }
}
