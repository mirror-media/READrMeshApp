import 'package:readr/models/baseModel.dart';

class Publisher {
  final String id;
  final String title;
  final String? officialSite;
  final String? summary;
  final String? logoUrl;
  final String? description;
  final String? lang;

  Publisher({
    required this.id,
    required this.title,
    this.officialSite,
    this.summary,
    this.logoUrl,
    this.description,
    this.lang,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    String? officialSite;
    String? summary;
    String? logoUrl;
    String? description;
    String? lang;

    if (BaseModel.checkJsonKeys(json, ['officialSite'])) {
      officialSite = json['officialSite'];
    }

    if (BaseModel.checkJsonKeys(json, ['summary'])) {
      summary = json['summary'];
    }

    if (BaseModel.checkJsonKeys(json, ['logo'])) {
      logoUrl = json['logo'];
    }

    if (BaseModel.checkJsonKeys(json, ['description'])) {
      description = json['description'];
    }

    if (BaseModel.checkJsonKeys(json, ['lang'])) {
      lang = json['lang'];
    }

    return Publisher(
      id: json['id'],
      title: json['title'],
      officialSite: officialSite,
      summary: summary,
      logoUrl: logoUrl,
      description: description,
      lang: lang,
    );
  }
}
