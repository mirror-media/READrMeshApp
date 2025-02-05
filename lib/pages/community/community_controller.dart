import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/services/community_service.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/communityListItem.dart';

class CommunityController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  final CommunityService _communityService;
  final scrollController = ScrollController();

  CommunityController(this._communityService);

  final isInitialized = false.obs;
  final isError = false.obs;
  final error = ''.obs;
  final isLoadingMore = false.obs;
  final communityList = <CommunityListItem>[].obs;
  final isNoMore = false.obs;

  int _currentPage = 0;
  static const int _pageSize = 10;

  void initPage() async {
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: Get.find<UserService>().currentUser.memberId,
        index: _currentPage,
        take: _pageSize,
      );

      if (data != null) {
        final mappedItems = data.stories
            .map((story) => CommunityListItem.fromJson(story))
            .toList();
        communityList.assignAll(mappedItems);
        _currentPage++;
      }

      isInitialized.value = true;
    } catch (e) {
      isError.value = true;
      error.value = e.toString();
    }
  }

  Future<void> updateCommunityPage() async {
    _currentPage = 0;
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: Get.find<UserService>().currentUser.memberId,
        index: _currentPage,
        take: _pageSize,
      );

      if (data != null) {
        communityList.assignAll(data.stories
            .map((item) => CommunityListItem.fromJson(item))
            .toList());
        _currentPage++;
      }
    } catch (e) {
      print('Error updating community page: $e');
    }
  }

  Future<void> fetchMoreFollowingPickedNews() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: Get.find<UserService>().currentUser.memberId,
        index: _currentPage,
        take: _pageSize,
      );

      if (data != null) {
        communityList.addAll(data.stories
            .map((item) => CommunityListItem.fromJson(item))
            .toList());
        _currentPage++;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> scrollToTopAndRefresh() async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    await updateCommunityPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
