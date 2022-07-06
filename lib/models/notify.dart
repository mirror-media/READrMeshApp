import 'package:hive/hive.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/member.dart';

part 'notify.g.dart';

@HiveType(typeId: 2)
class Notify {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Member sender;
  @HiveField(2)
  final NotifyType type;
  @HiveField(3)
  final String objectId;
  @HiveField(4)
  final DateTime actionTime;
  @HiveField(5)
  bool isRead;

  Notify({
    required this.id,
    required this.sender,
    required this.type,
    required this.objectId,
    required this.actionTime,
    this.isRead = false,
  });

  factory Notify.fromJson(Map<String, dynamic> json) {
    bool isRead = false;
    if (BaseModel.checkJsonKeys(json, ['state']) && json['state'] == 'read') {
      isRead = true;
    }

    NotifyType type = NotifyType.follow;
    if (json['type'] == 'comment' && json['objective'] == 'story') {
      type = NotifyType.comment;
    } else if (json['type'] == 'comment' && json['objective'] == 'collection') {
      type = NotifyType.commentCollection;
    } else if (json['type'] == 'create_collection') {
      type = NotifyType.createCollection;
    } else if (json['type'] == 'heart') {
      type = NotifyType.like;
    } else if (json['type'] == 'pick') {
      type = NotifyType.pickCollection;
    }

    return Notify(
      id: json['id'],
      objectId: json['object_id'].toString(),
      actionTime: DateTime.parse(json['action_date']),
      sender: Member.fromJson(json['sender']),
      isRead: isRead,
      type: type,
    );
  }
}
