import 'package:readr/models/baseModel.dart';
import 'package:readr/models/newsListItem.dart';

class EditorChoiceItem {
  final String? id;
  final String? url;
  final bool isProject;
  NewsListItem? newsListItem;

  EditorChoiceItem({
    this.id,
    this.url,
    this.isProject = false,
    this.newsListItem,
  });

  factory EditorChoiceItem.fromJson(Map<String, dynamic> json) {
    String? id;
    String? style;
    bool isProject = false;
    String? link;
    if (json['choice'] != null) {
      id = json['choice'][BaseModel.idKey];
      style = json['choice']['style'];
      if (style == 'project3' || style == 'embedded' || style == 'report') {
        isProject = true;
      }
    } else {
      link = json['link'];
      if (!isProject) {
        if (link!.contains('project')) {
          isProject = true;
        }
      }
    }

    return EditorChoiceItem(
      id: id,
      url: link,
      isProject: isProject,
    );
  }
}
