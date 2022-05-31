import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';

class HiveService extends GetxService {
  late final Box<Member> memberBox;

  Future<HiveService> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(PublisherAdapter());
    memberBox = await Hive.openBox<Member>('memberBox');
    return this;
  }

  Member get localMember {
    return memberBox.get('currentUser') ??
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
    memberBox.put('currentUser', member);
  }

  void deleteLocalMember() {
    memberBox.delete('currentUser');
  }
}
