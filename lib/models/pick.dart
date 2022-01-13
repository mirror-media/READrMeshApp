import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class Pick {
  final String id;
  final Member member;
  final NewsListItem story;
  final String objective;
  final Comment? comment;
  final Comment? pickComment;
  final DateTime pickedDate;

  Pick({
    required this.id,
    required this.member,
    required this.story,
    required this.objective,
    this.comment,
    this.pickComment,
    required this.pickedDate,
  });

  factory Pick.fromJson(Map<String, dynamic> json) {
    return Pick(
      id: json["id"],
      member: Member.fromJson(json["member"]),
      story: NewsListItem.fromJson(json["story"]),
      pickedDate: DateTime.parse(json["picked_date"]).toLocal(),
      objective: json["objective"],
    );
  }
}
