import 'package:readr/helpers/dataConstants.dart';

class PickIdItem {
  final PickObjective objective;
  final PickKind kind;
  final String targetId;
  final String? myPickId;
  final String? myPickCommentId;
  final String? myBookmarkId;

  const PickIdItem({
    required this.objective,
    required this.kind,
    required this.targetId,
    this.myPickId,
    this.myPickCommentId,
    this.myBookmarkId,
  });

  factory PickIdItem.fromJson(
      Map<String, dynamic> json, PickObjective objective, PickKind kind) {
    String targetId;
    String? myPickId;
    String? myPickCommentId;
    String? myBookmarkId;

    switch (objective) {
      case PickObjective.story:
        targetId = json['story']['id'];

        break;
      case PickObjective.comment:
        targetId = json['comment']['id'];
        break;
      case PickObjective.collection:
        targetId = json['collection']['id'];
        break;
    }

    switch (kind) {
      case PickKind.bookmark:
        myBookmarkId = json['id'];
        break;
      case PickKind.collect:
        break;
      case PickKind.read:
        myPickId = json['id'];
        if (json.containsKey('pick_comment') &&
            json['pick_comment'].isNotEmpty) {
          myPickCommentId = json['pick_comment'][0]['id'];
        }
        break;
    }

    return PickIdItem(
      objective: objective,
      targetId: targetId,
      kind: kind,
      myPickId: myPickId,
      myPickCommentId: myPickCommentId,
      myBookmarkId: myBookmarkId,
    );
  }
}
