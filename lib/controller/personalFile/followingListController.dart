import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/personalFileService.dart';

class FollowingListController extends GetxController {
  final PersonalFileRepos personalFileRepos;
  final Member viewMember;
  FollowingListController({
    required this.personalFileRepos,
    required this.viewMember,
  });

  final isLoadingMore = false.obs;
  final followingMemberList = <Member>[].obs;
  int followingMemberCount = 0;
  final List<Publisher> followingPublisherList = [];
  final isNoMore = false.obs;
  final isExpanded = false.obs;

  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    initPage();
    super.onInit();
  }

  void initPage() async {
    isLoading = true;
    isError = false;
    update();
    await fetchFollowingList();
  }

  Future<void> fetchFollowingList() async {
    try {
      Map<String, dynamic> followingMemberResult = {};

      await Future.wait([
        personalFileRepos
            .fetchFollowingList(viewMember)
            .then((value) => followingMemberResult = value),
        personalFileRepos
            .fetchFollowPublisher(viewMember)
            .then((value) => followingPublisherList.assignAll(value)),
      ]);

      followingMemberList.assignAll(followingMemberResult['followingList']);
      followingMemberCount = followingMemberResult['followingMemberCount'];
      if (followingMemberCount < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch member${viewMember.memberId} following list error: $e');
      isError = true;
      error = determineException(e);
    }
    isLoading = false;
    update();
  }

  void fetchMoreFollowingMember() async {
    isLoadingMore.value = true;
    try {
      var result = await personalFileRepos.fetchFollowingList(viewMember,
          skip: followingMemberList.length);
      followingMemberList.addAll(result['followingList']);
      if (result['followingList'].length < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print(
          'Fetch member${viewMember.memberId} more following member error: $e');
      Fluttertoast.showToast(
        msg: "載入更多失敗",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isLoadingMore.value = false;
  }
}
