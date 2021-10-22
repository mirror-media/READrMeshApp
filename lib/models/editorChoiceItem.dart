import 'package:readr/models/baseModel.dart';
import 'package:readr/models/paragrpahList.dart';

class EditorChoiceItem {
  String? id;
  String name;
  String? link;
  String? slug;
  String? style;
  String? photoUrl;
  ParagraphList? summary;
  bool isProject;

  EditorChoiceItem({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.style,
    this.slug,
    this.link,
    this.summary,
    this.isProject = false,
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
    bool isProject = false;
    if (json['choice'] != null) {
      id = json['choice'][BaseModel.idKey];
      slug = json['choice'][BaseModel.slugKey];
      style = json['choice']['style'];
      summary = json['choice']['style'];
      if (style == 'project3' || style == 'embedded' || style == 'report') {
        isProject = true;
      }
    }

    String link = json['link'];
    if (!isProject) {
      if (link.contains('project')) {
        isProject = true;
      } else {
        final linkList = link.split("/");
        id ??= linkList.last;
      }
    }

    return EditorChoiceItem(
      id: id,
      name: json[BaseModel.nameKey],
      slug: slug,
      style: style,
      photoUrl: photoUrl,
      link: link,
      isProject: isProject,
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
