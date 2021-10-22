import 'dart:convert';

import 'package:readr/models/category.dart';
import 'package:readr/models/customizedList.dart';

class CategoryList extends CustomizedList<Category> {
  // constructor
  CategoryList();

  factory CategoryList.fromJson(List<dynamic> parsedJson) {
    CategoryList categories = CategoryList();
    categories.innerList = parsedJson.map((i) => Category.fromJson(i)).toList();

    return categories;
  }

  factory CategoryList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return CategoryList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> categoryMaps = List.empty(growable: true);

    for (Category category in this) {
      categoryMaps.add(category.toJson());
    }
    return categoryMaps;
  }
}
