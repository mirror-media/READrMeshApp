import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class Pick {
  final String id;
  final Member member;
  final NewsListItem? story;
  final PickObjective objective;
  final Comment? comment;
  Comment? pickComment;
  final DateTime pickedDate;
  final Collection? collection;

  Pick({
    required this.id,
    required this.member,
    this.story,
    required this.objective,
    this.comment,
    this.pickComment,
    required this.pickedDate,
    this.collection,
  });

  factory Pick.fromJson(Map<String, dynamic> json) {
    NewsListItem? story;
    Comment? comment;
    Comment? pickComment;
    PickObjective pickObjective = PickObjective.story;
    Collection? collection;
    if (json['objective'] == 'comment') {
      pickObjective = PickObjective.comment;
    } else if (json['objective'] == 'collection') {
      pickObjective = PickObjective.collection;
    }

    if (pickObjective == PickObjective.story) {
      story = NewsListItem.fromJson(json["story"]);
    } else if (pickObjective == PickObjective.comment) {
      comment = Comment.fromJson(json["comment"]);
    } else {
      collection = Collection.fromPickTabJson(json['collection']);
    }

    if (json["pick_comment"] != null && json["pick_comment"].isNotEmpty) {
      pickComment = Comment.fromJson(json["pick_comment"][0]);
    }

    return Pick(
      id: json["id"],
      member: Member.fromJson(json["member"]),
      story: story,
      comment: comment,
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
      objective: pickObjective,
      pickComment: pickComment,
      collection: collection,
    );
  }
}
