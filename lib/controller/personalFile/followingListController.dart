import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
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
  final followingMemberCount = 0.obs;
  final followingPublisherList = <Publisher>[].obs;
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
    isError = await fetchFollowingList();
    isLoading = false;
    update();
  }

  Future<bool> fetchFollowingList() async {
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
      followingMemberCount.value =
          followingMemberResult['followingMemberCount'];
      if (followingMemberList.length == followingMemberCount.value) {
        isNoMore.value = true;
      }

      var personalFilePageController =
          Get.find<PersonalFilePageController>(tag: viewMember.memberId);
      personalFilePageController.followingCount.value =
          followingPublisherList.length + followingMemberCount.value;

      return false;
    } catch (e) {
      print('Fetch member${viewMember.memberId} following list error: $e');
      error = determineException(e);
      return true;
    }
  }

  void fetchMoreFollowingMember() async {
    isLoadingMore.value = true;
    try {
      var result = await personalFileRepos.fetchFollowingList(viewMember,
          skip: followingMemberList.length);
      List<Member> newFollowingMember = result['followingList'] as List<Member>;
      followingMemberList.addAll(newFollowingMember);

      if (followingMemberList.length == followingMemberCount.value) {
        isNoMore.value = true;
      } else if (followingMemberList.length > followingMemberCount.value) {
        followingMemberCount.value = followingMemberList.length;
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

  void removePublisherItem(String publisherId) {
    followingPublisherList.removeWhere((element) => element.id == publisherId);
  }

  void removeMemberItem(String memberId) {
    followingMemberList.removeWhere((element) => element.memberId == memberId);
  }
}
