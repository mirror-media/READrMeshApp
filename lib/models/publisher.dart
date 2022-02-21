import 'package:readr/models/baseModel.dart';

class Publisher {
  final String id;
  final String title;
  final String? officialSite;
  final String? summary;
  final String? logoUrl;
  final String? description;
  final String? lang;
  final bool fullContent;
  final bool fullScreenAd;
  final String? customId;

  Publisher({
    required this.id,
    required this.title,
    this.officialSite,
    this.summary,
    this.logoUrl,
    this.description,
    this.lang,
    this.fullContent = false,
    this.fullScreenAd = false,
    this.customId,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    String? officialSite;
    String? summary;
    String? logoUrl;
    String? description;
    String? lang;
    bool fullContent = false;
    bool fullScreenAd = false;
    String? customId;

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

    if (BaseModel.checkJsonKeys(json, ['full_content'])) {
      fullContent = json['full_content'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_screen_ad'])) {
      if (json['full_screen_ad'] == 'all' ||
          json['full_screen_ad'] == 'mobile') {
        fullScreenAd = true;
      }
    }

    if (BaseModel.checkJsonKeys(json, ['customId'])) {
      customId = json['customId'];
    }

    return Publisher(
      id: json['id'],
      title: json['title'],
      officialSite: officialSite,
      summary: summary,
      logoUrl: logoUrl,
      description: description,
      lang: lang,
      fullContent: fullContent,
      fullScreenAd: fullScreenAd,
      customId: customId,
    );
  }
}
