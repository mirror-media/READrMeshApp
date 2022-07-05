import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/notify.dart';

class NotifyPageItem {
  final String id;
  final NotifyType type;
  final List<Member> senderList;
  final String objectId;
  DateTime actionTime;
  bool isRead;
  final List<Notify> relatedNotifies;
  NewsListItem? newsListItem;
  Collection? collection;
  Comment? comment;

  NotifyPageItem({
    required this.id,
    required this.type,
    required this.senderList,
    required this.objectId,
    required this.actionTime,
    required this.isRead,
    required this.relatedNotifies,
    this.newsListItem,
    this.collection,
    this.comment,
  });

  factory NotifyPageItem.fromNotify(Notify notify) {
    return NotifyPageItem(
      id: notify.id,
      type: notify.type,
      senderList: [notify.sender],
      objectId: notify.objectId,
      actionTime: notify.actionTime,
      isRead: notify.isRead,
      relatedNotifies: [notify],
    );
  }
}
