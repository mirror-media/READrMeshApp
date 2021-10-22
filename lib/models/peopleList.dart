import 'dart:convert';

import 'package:readr/models/customizedList.dart';
import 'package:readr/models/people.dart';

class PeopleList extends CustomizedList<People> {
  // constructor
  PeopleList();

  factory PeopleList.fromJson(List<dynamic> parsedJson) {
    PeopleList peoples = PeopleList();
    List parseList = parsedJson.map((i) => People.fromJson(i)).toList();
    for (var element in parseList) {
      peoples.add(element);
    }

    return peoples;
  }

  factory PeopleList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return PeopleList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> peopleMaps = List.empty(growable: true);
    for (People people in this) {
      peopleMaps.add(people.toJson());
    }
    return peopleMaps;
  }

  String toJsonString() {
    List<Map> peopleMaps = List.empty(growable: true);
    for (People people in this) {
      peopleMaps.add(people.toJson());
    }
    return json.encode(peopleMaps);
  }
}
