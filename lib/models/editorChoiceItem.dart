import 'package:intl/intl.dart';
import 'package:readr/models/baseModel.dart';

class EditorChoiceItem {
  String? id;
  String name;
  String? link;
  String? slug;
  String? style;
  String? photoUrl;
  String? summary;
  bool isProject;
  String publishTimeString;
  int readingTime;

  EditorChoiceItem({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.publishTimeString,
    this.style,
    this.slug,
    this.link,
    this.summary,
    this.isProject = false,
    required this.readingTime,
  });

  factory EditorChoiceItem.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json['choice'], ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['choice']['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json['choice'], ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['choice']['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    String? id;
    String? slug;
    String? style;
    String? summary;
    int readingTime = 10;
    bool isProject = false;
    if (json['choice'] != null) {
      id = json['choice'][BaseModel.idKey];
      slug = json['choice'][BaseModel.slugKey];
      style = json['choice']['style'];
      summary = json['choice']['ogDescription'];
      readingTime = json['choice']['readingTime'] ?? 10;
      if (style == 'project3' || style == 'embedded' || style == 'report') {
        isProject = true;
      }
    }

    String link = json['link'];
    if (!isProject) {
      if (link.contains('project')) {
        isProject = true;
      }
    }

    DateTime publishTime = DateTime.now();
    if (json['publishTime'] != null) {
      publishTime = DateTime.parse(json['publishTime']).toLocal();
    }

    return EditorChoiceItem(
      id: id,
      name: json[BaseModel.nameKey],
      slug: slug,
      style: style,
      photoUrl: photoUrl,
      link: link,
      summary: summary,
      isProject: isProject,
      publishTimeString: DateFormat('MM/dd').format(publishTime),
      readingTime: readingTime,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
        'style': style,
        'photoUrl': photoUrl,
        'link': link,
        'isProject': isProject,
      };
}
