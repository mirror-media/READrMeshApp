import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class UserHelper {
  UserHelper._internal();

  factory UserHelper() => _instance;

  static late final UserHelper _instance = UserHelper._internal();

  static UserHelper get instance => _instance;

  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  bool _isInitialized = false;
  late Member _member;

  bool get isMember => FirebaseAuth.instance.currentUser != null;

  bool get isVisitor => FirebaseAuth.instance.currentUser == null;

  bool get isInitialized => _isInitialized;

  List<Member> _localFollowingMemberList = [];
  List<Publisher> _localFollowingPublisherList = [];

  // if want to use member, must call fetchUserData() once
  Member get currentUser => _member;

  // fetch the member or visitor data
  Future<void> fetchUserData() async {
    if (isMember) {
      _member = await _memberService.fetchMemberData();
    } else {
      _member = await _visitorService.fetchMemberData();
    }
    _isInitialized = true;
    _localFollowingMemberList = _member.following;
    _localFollowingPublisherList = _member.followingPublisher;
  }

  // check whether member is currentUser's following member
  bool isFollowingMember(Member member) {
    if (!_isInitialized) {
      return false;
    } else {
      for (var following in _member.following) {
        if (following.memberId == member.memberId) {
          member.isFollowing = true;
          return true;
        }
      }
      return false;
    }
  }

  // add following member
  Future<bool> addFollowingMember(String memberId) async {
    List<Member>? newFollowingList;
    if (isMember) {
      newFollowingList = await _memberService.addFollowingMember(memberId);
    } else {
      newFollowingList = await _visitorService.addFollowingMember(memberId);
    }

    return _checkUpdateFollowingResult(_member.following, newFollowingList);
  }

  // remove following member
  Future<bool> removeFollowingMember(String memberId) async {
    List<Member>? newFollowingList;
    if (isMember) {
      newFollowingList = await _memberService.removeFollowingMember(memberId);
    } else {
      newFollowingList = await _visitorService.removeFollowingMember(memberId);
    }

    return _checkUpdateFollowingResult(_member.following, newFollowingList);
  }

  // check whether publisher is currentUser's following publisher
  bool isFollowingPublisher(Publisher publisher) {
    if (!_isInitialized) {
      return false;
    } else {
      for (var following in _member.followingPublisher) {
        if (following.id == publisher.id) {
          return true;
        }
      }
      return false;
    }
  }

  // add publisher
  Future<bool> addFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (isMember) {
      newFollowingList = await _memberService.addFollowPublisher(publisherId);
    } else {
      newFollowingList = await _visitorService.addFollowPublisher(publisherId);
    }

    return _checkUpdateFollowingResult(
        _member.followingPublisher, newFollowingList);
  }

  // remove publisher
  Future<bool> removeFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (isMember) {
      newFollowingList =
          await _memberService.removeFollowPublisher(publisherId);
    } else {
      newFollowingList =
          await _visitorService.removeFollowPublisher(publisherId);
    }

    return _checkUpdateFollowingResult(
        _member.followingPublisher, newFollowingList);
  }

  bool _checkUpdateFollowingResult(dynamic oldObject, dynamic newObject) {
    if (newObject == null) {
      syncFollowing();
      return false;
    } else {
      oldObject = newObject;
      syncFollowing();
      return true;
    }
  }

  // local following list

  bool isLocalFollowingMember(Member member) {
    return _localFollowingMemberList
        .any((element) => element.memberId == member.memberId);
  }

  bool isLocalFollowingPublisher(Publisher publisher) {
    return _localFollowingPublisherList
        .any((element) => element.id == publisher.id);
  }

  void updateLocalFollowingMember(Member member) {
    int index = _localFollowingMemberList
        .indexWhere((element) => element.memberId == member.memberId);
    if (index == -1) {
      _localFollowingMemberList.add(member);
    } else {
      _localFollowingMemberList.removeAt(index);
    }
  }

  void updateLocalFollowingPublisher(Publisher publisher) {
    int index = _localFollowingPublisherList
        .indexWhere((element) => element.id == publisher.id);
    if (index == -1) {
      _localFollowingPublisherList.add(publisher);
    } else {
      _localFollowingPublisherList.removeAt(index);
    }
  }

  void syncFollowing() {
    _localFollowingMemberList = _member.following;
    _localFollowingPublisherList = _member.followingPublisher;
  }
}
