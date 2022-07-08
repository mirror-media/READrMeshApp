import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/notify.dart';
import 'package:readr/models/publisher.dart';

class HiveService extends GetxService {
  late final Box<Member> _memberBox;
  late final Box _notifyBox;
  late final Box<bool> tooltipBox;

  Future<HiveService> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(PublisherAdapter());
    Hive.registerAdapter(NotifyAdapter());
    Hive.registerAdapter(NotifyTypeAdapter());
    _memberBox = await Hive.openBox<Member>('memberBox');
    _notifyBox = await Hive.openBox('notifyBox');
    tooltipBox = await Hive.openBox<bool>('tooltipBox');
    return this;
  }

  Member get localMember {
    return _memberBox.get('currentUser') ??
        Member(
          memberId: "-1",
          nickname: "訪客",
          customId: "Visitor",
          following: [],
          followingPublisher: [],
          avatar: null,
        );
  }

  void updateLocalMember(Member member) {
    _memberBox.put('currentUser', member);
  }

  void deleteLocalMember() {
    _memberBox.delete('currentUser');
  }

  List<Notify> get localNotifies {
    return List<Notify>.from(_notifyBox.get('notifyList', defaultValue: []));
  }

  void updateNotifyList(List<Notify> notifies) {
    _notifyBox.put('notifyList', notifies);
  }

  void deleteNotifyList() {
    _notifyBox.delete('notifyList');
  }
}
