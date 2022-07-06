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

    return Announcement(
      type: type,
      content: json['name'],
    );
  }
}
