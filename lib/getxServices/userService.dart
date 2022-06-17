import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class UserService extends GetxService {
  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  bool get _isMember => FirebaseAuth.instance.currentUser != null;

  final isMember = false.obs;

  late Member currentUser;
  bool hasInvitationCode = false;

  Duration get _timeout {
    if (Get.find<EnvironmentService>().flavor == BuildFlavor.development) {
      return const Duration(minutes: 3);
    }
    return const Duration(minutes: 1);
  }

  Future<UserService> init() async {
    await fetchUserData();
    return this;
  }

  Future<void> fetchUserData({Member? member}) async {
    if (member != null) {
      currentUser = member;
    } else if (_isMember) {
      var memberData =
          await _memberService.fetchMemberData().catchError((error) {
        print('Fetch user data failed: $error');
        return Get.find<HiveService>().localMember;
      }).timeout(
        _timeout,
        onTimeout: () {
          print('Fetch user data timeout');
          return Get.find<HiveService>().localMember;
        },
      );

      if (memberData != null) {
        currentUser = memberData;
      }
    } else {
      currentUser = await _visitorService.fetchMemberData().catchError((error) {
        print('Fetch visitor data failed: $error');
        return Get.find<HiveService>().localMember;
      }).timeout(
        _timeout,
        onTimeout: () {
          print('Fetch user data timeout');
          return Get.find<HiveService>().localMember;
        },
      );
    }
    isMember.value = _isMember;
    Get.find<HiveService>().updateLocalMember(currentUser);
    AnalyticsHelper.setUserId(currentUser.memberId);
  }

  bool isFollowingMember(Member member) {
    return currentUser.following
        .any((element) => element.memberId == member.memberId);
  }

  Future<bool> addFollowingMember(String memberId) async {
    List<Member>? newFollowingList =
        await _memberService.addFollowingMember(memberId);

    if (newFollowingList != null) {
      currentUser.following = newFollowingList;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeFollowingMember(String memberId) async {
    List<Member>? newFollowingList =
        await _memberService.removeFollowingMember(memberId);

    if (newFollowingList != null) {
      currentUser.following = newFollowingList;
      return true;
    } else {
      return false;
    }
  }

  bool isFollowingPublisher(Publisher publisher) {
    return currentUser.followingPublisher
        .any((element) => element.id == publisher.id);
  }

  Future<bool> addFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (_isMember) {
      newFollowingList = await _memberService.addFollowPublisher(publisherId);
    } else {
      newFollowingList = await _visitorService.addFollowPublisher(publisherId);
    }

    if (newFollowingList != null) {
      currentUser.followingPublisher = newFollowingList;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (_isMember) {
      newFollowingList =
          await _memberService.removeFollowPublisher(publisherId);
    } else {
      newFollowingList =
          await _visitorService.removeFollowPublisher(publisherId);
    }

    if (newFollowingList != null) {
      currentUser.followingPublisher = newFollowingList;
      return true;
    } else {
      return false;
    }
  }

  Future<void> addVisitorFollowing(List<String> followingPublisherIds) async {
    List<Future> futureList = [];
    for (var publisherId in followingPublisherIds) {
      futureList.add(_memberService.addFollowPublisher(publisherId));
    }
    await Future.wait(futureList);

    await fetchUserData();
  }

  List<String> get followingMemberIds {
    return List<String>.from(currentUser.following.map((e) => e.memberId));
  }

  List<String> get followingPublisherIds {
    return List<String>.from(currentUser.followingPublisher.map((e) => e.id));
  }
}
