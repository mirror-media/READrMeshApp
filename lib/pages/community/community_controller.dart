import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/services/community_service.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/controller/pick/pickableItemController.dart';

class CommunityController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  late final CommunityService _communityService;
  late final UserService _userService;
  final scrollController = ScrollController();

  CommunityController() {
    _communityService = Get.find<CommunityService>();
    _userService = Get.find<UserService>();
  }

  UserService get userService => _userService;
  bool get isMember => _userService.isMember.value;

  getPickableItemController(String tag) {
    return Get.find<PickableItemController>(tag: tag);
  }

  final isInitialized = false.obs;
  final isError = false.obs;
  final rxError = Rxn<String>();
  final isLoadingMore = false.obs;
  final communityList = <CommunityListItem>[].obs;
  final isNoMore = false.obs;

  int _currentPage = 0;
  static const int _pageSize = 10;

  final recommendMembers = <Member>[].obs;

  Future<void> _fetchRecommendMembers(List<dynamic> membersJson) async {
    try {
      final members =
          membersJson.map((memberJson) => Member.fromJson(memberJson)).toList();
      recommendMembers.assignAll(members);
    } catch (e) {
      print('Error fetching recommend members: $e');
    }
    return;
  }

  void initPage() async {
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: _userService.currentUser.memberId,
        index: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (data != null) {
        final mappedItems = data.stories
            .map((story) => CommunityListItem.fromJson(story))
            .toList();
        communityList.assignAll(mappedItems);

        if (data.members.isNotEmpty) {
          await _fetchRecommendMembers(data.members);
        }

        _currentPage++;
      }

      isInitialized.value = true;
    } catch (e) {
      isError.value = true;
      rxError.value = e.toString();
    }
  }

  Future<void> updateCommunityPage() async {
    _currentPage = 0;
    isNoMore.value = false;
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: _userService.currentUser.memberId,
        index: _currentPage * _pageSize,
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
    if (isLoadingMore.value || isNoMore.value) return;

    isLoadingMore.value = true;
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: _userService.currentUser.memberId,
        index: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (data != null && data.stories.isNotEmpty) {
        final newItems = data.stories
            .map((item) => CommunityListItem.fromJson(item))
            .toList();
        communityList.addAll(newItems);
        _currentPage++;

        if (newItems.length < _pageSize) {
          isNoMore.value = true;
        }
      } else {
        isNoMore.value = true;
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
