import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class PickedItem {
  String pickId;
  int pickCount;
  String? pickCommentId;
  PickedItem({
    required this.pickId,
    required this.pickCount,
    this.pickCommentId,
  });
}

class UserService extends GetxService {
  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();
  final InvitationCodeService _invitationCodeService = InvitationCodeService();

  bool get isMember => FirebaseAuth.instance.currentUser != null;

  bool get isVisitor => FirebaseAuth.instance.currentUser == null;

  late Member currentUser;
  bool hasInvitationCode = false;

  final Map<String, PickedItem> _newsPickedMap = {};

  Future<UserService> init() async {
    await fetchUserData();
    return this;
  }

  Future<void> fetchUserData({Member? member}) async {
    if (member != null) {
      currentUser = member;
    } else if (isMember) {
      var memberData = await _memberService.fetchMemberData();
      if (memberData != null) {
        currentUser = memberData;
        await checkInvitationCode();
      } else {
        await FirebaseAuth.instance.signOut();
        currentUser = await _visitorService.fetchMemberData();
      }
    } else {
      currentUser = await _visitorService.fetchMemberData();
    }
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
    if (isMember) {
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
    if (isMember) {
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

  void updateNewsPickedMap(String newsId, PickedItem? item) {
    if (item != null) {
      _newsPickedMap.update(
        newsId,
        (value) => item,
        ifAbsent: () => item,
      );
    } else {
      _newsPickedMap.remove(newsId);
    }
  }

  bool isNewsPicked(String newsId) {
    if (isVisitor) return false;
    return _newsPickedMap.containsKey(newsId);
  }

  PickedItem? getNewsPickedItem(String newsId) {
    return _newsPickedMap[newsId];
  }

  void removeNewsPickCommentId(String newsId) {
    _newsPickedMap[newsId]?.pickCommentId == null;
  }

  PickedItem? getNewsPickedItemByPickCommentId(String commentId) {
    PickedItem? newsPickedItem;
    _newsPickedMap.forEach((key, value) {
      if (value.pickCommentId == commentId) {
        newsPickedItem = value;
      }
    });
    return newsPickedItem;
  }

  Future<void> checkInvitationCode() async {
    hasInvitationCode = await _invitationCodeService
        .checkUsableInvitationCode(currentUser.memberId);
  }
}
