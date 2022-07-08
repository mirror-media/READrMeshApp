import 'package:readr/models/baseModel.dart';

enum AnnouncementType {
  maintain,
  newFeature,
}

class Announcement {
  final AnnouncementType type;
  final String content;

  const Announcement({
    required this.type,
    required this.content,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    AnnouncementType type = AnnouncementType.maintain;
    if (BaseModel.checkJsonKeys(json, ['type']) && json['type'] == 'features') {
      type = AnnouncementType.newFeature;
    }
    return Announcement(
      type: type,
      content: json['name'],
    );
  }
}
