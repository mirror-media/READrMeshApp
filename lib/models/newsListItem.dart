import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/publisher.dart';

class NewsListItem {
  final String id;
  final String title;
  final String url;
  final String? summary;
  final Publisher? source;
  final Category? category;
  final DateTime publishedDate;
  final String heroImageUrl;

  NewsListItem({
    required this.id,
    required this.title,
    required this.url,
    this.summary,
    this.source,
    this.category,
    required this.publishedDate,
    required this.heroImageUrl,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    Publisher? source;
    Category? category;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['category'])) {
      category = Category.fromJson(json['source']);
    }

    return NewsListItem(
      id: json["id"],
      title: json["title"],
      url: json["url"],
      summary: json["summary"],
      source: source,
      category: category,
      publishedDate: DateTime.parse(json["published_date"]).toLocal(),
      heroImageUrl: json["og_image"],
    );
  }
}
