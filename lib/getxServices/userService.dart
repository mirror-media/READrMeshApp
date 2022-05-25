import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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

  int _errorTime = 0;

  Future<UserService> init() async {
    await fetchUserData().catchError(
      (error) async {
        print('Fetch user data failed: $error');
        await Future.delayed(Duration(seconds: _errorTime * 30));
        _errorTime++;
        if (_errorTime < 5) {
          Fluttertoast.showToast(
            msg: '伺服器發生錯誤，嘗試重新連線...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            fontSize: 16.0,
          );
          await init();
        } else {
          Fluttertoast.showToast(
            msg: '伺服器離線 請稍後再重新啟動',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 60,
            fontSize: 16.0,
          );
          _errorTime = 0;
          SystemNavigator.pop();
        }
      },
    ).timeout(
      const Duration(seconds: 90),
      onTimeout: () async {
        print('Fetch user data timeout');
        _errorTime++;
        if (_errorTime < 5) {
          Fluttertoast.showToast(
            msg: '連線逾時 ${_errorTime * 10}秒後重新連線...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            fontSize: 16.0,
          );
          await Future.delayed(Duration(seconds: _errorTime * 10));
          await init();
        } else {
          Fluttertoast.showToast(
            msg: '連線失敗 請檢查網路連接後重新啟動',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 60,
            fontSize: 16.0,
          );
          _errorTime = 0;
          SystemNavigator.pop();
        }
      },
    );
    return this;
  }

  Future<void> fetchUserData({Member? member}) async {
    if (member != null) {
      currentUser = member;
    } else if (_isMember) {
      var memberData = await _memberService.fetchMemberData();
      if (memberData != null) {
        currentUser = memberData;
      } else {
        await FirebaseAuth.instance.signOut();
        currentUser = await _visitorService.fetchMemberData();
      }
    } else {
      currentUser = await _visitorService.fetchMemberData();
    }
    isMember.value = _isMember;
    _errorTime = 0;
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
}
