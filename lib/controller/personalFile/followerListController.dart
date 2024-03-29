import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/personalFileService.dart';

class FollowerListController extends GetxController {
  final PersonalFileRepos personalFileRepos;
  final Member viewMember;
  FollowerListController({
    required this.personalFileRepos,
    required this.viewMember,
  });

  final isLoadingMore = false.obs;
  final followerList = <Member>[].obs;
  final isNoMore = false.obs;

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
    isError = await fetchFollowerList();
    isLoading = false;
    update();
  }

  Future<bool> fetchFollowerList() async {
    try {
      followerList
          .assignAll(await personalFileRepos.fetchFollowerList(viewMember));
      if (followerList.length < 10) {
        isNoMore.value = true;
      }
      return false;
    } catch (e) {
      print('Fetch member${viewMember.memberId} follower list error: $e');
      error = determineException(e);
      return true;
    }
  }

  void fetchMoreFollower() async {
    isLoadingMore.value = true;
    try {
      List<Member> moreFollowerList = await personalFileRepos
          .fetchFollowerList(viewMember, skip: followerList.length);
      followerList.addAll(moreFollowerList);
      if (moreFollowerList.length < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch member${viewMember.memberId} more follower error: $e');
      Fluttertoast.showToast(
        msg: "loadMoreFailedToast".tr,
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
