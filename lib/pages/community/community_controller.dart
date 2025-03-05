import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/services/community_service.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/followableItem.dart';

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

  String getAuthorText(CommunityListItem item) {
    final authorTextValue = item.authorText.value;
    final isMember = userService.isMember;

    if (item.type == CommunityListItemType.commentStory ||
        item.type == CommunityListItemType.pickStory) {
      return authorTextValue ?? '';
    } else if (isMember.isTrue &&
        userService.currentUser.memberId == item.collection!.creator.memberId) {
      return '@${userService.currentUser.customId}';
    } else {
      return '@${authorTextValue ?? ''}';
    }
  }

  String getItemTitle(CommunityListItem item) {
    final titleTextValue = item.titleText.value;

    if (item.type != CommunityListItemType.commentStory &&
        item.type != CommunityListItemType.pickStory) {
      final pickableController =
          getPickableItemController(item.collection!.controllerTag);
      final collectionTitleValue = pickableController.collectionTitle.value;
      return collectionTitleValue ?? titleTextValue;
    }

    return titleTextValue;
  }

  bool shouldShowCollectionTag(CommunityListItem item) {
    return item.type != CommunityListItemType.commentStory &&
        item.type != CommunityListItemType.pickStory;
  }

  PickObjective getCommentObjective(CommunityListItem item) {
    switch (item.type) {
      case CommunityListItemType.commentStory:
      case CommunityListItemType.pickStory:
        return PickObjective.story;
      case CommunityListItemType.pickCollection:
      case CommunityListItemType.commentCollection:
      case CommunityListItemType.createCollection:
      case CommunityListItemType.updateCollection:
        return PickObjective.collection;
      default:
        throw Exception('未知的項目類型');
    }
  }

  List<Member> getFirstTwoMembers(CommunityListItem item) {
    List<Member> firstTwoMember = [];
    for (int i = 0; i < item.itemBarMember.length; i++) {
      if (!firstTwoMember.any(
          (element) => element.memberId == item.itemBarMember[i].memberId)) {
        firstTwoMember.add(item.itemBarMember[i]);
      }
      if (firstTwoMember.length == 2) {
        break;
      }
    }
    return firstTwoMember;
  }

  Future<Map<String, dynamic>> getMoreActionSheetInfo(
      CommunityListItem item) async {
    PickObjective objective;
    String? url;

    if (item.type == CommunityListItemType.pickStory ||
        item.type == CommunityListItemType.commentStory) {
      objective = PickObjective.story;
      url = item.newsListItem!.url;
    } else {
      objective = PickObjective.collection;
      url = await DynamicLinkHelper.createCollectionLink(item.collection!);
    }

    return {
      'objective': objective,
      'url': url,
    };
  }

  bool shouldShowBottomWidget() {
    return isMember;
  }

  bool shouldShowNoMoreContent() {
    return isNoMore.value;
  }

  void handleVisibilityChanged(double visiblePercentage) {
    if (visiblePercentage > 50 && !isLoadingMore.value) {
      fetchMoreFollowingPickedNews();
    }
  }

  List<MemberFollowableItem> getRecommendMemberFollowableItems() {
    return recommendMembers.map((m) => MemberFollowableItem(m)).toList();
  }

  bool hasRecommendMembers() {
    return recommendMembers.isNotEmpty;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
