import 'package:readr/helpers/dataConstants.dart';

class PickIdItem {
  final PickObjective objective;
  final PickKind kind;
  final String targetId;
  final String? myPickCommentId;

  const PickIdItem({
    required this.objective,
    required this.kind,
    required this.targetId,
    this.myPickCommentId,
  });

  factory PickIdItem.fromJson(
      Map<String, dynamic> json, PickObjective objective, PickKind kind) {
    String targetId;
    String? myPickCommentId;

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

    if (kind == PickKind.read) {
      if (json.containsKey('pick_comment') && json['pick_comment'].isNotEmpty) {
        myPickCommentId = json['pick_comment'][0]['id'];
      }
    }

    return PickIdItem(
      objective: objective,
      targetId: targetId,
      kind: kind,
      myPickCommentId: myPickCommentId,
    );
  }
}
