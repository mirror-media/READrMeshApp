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
import 'package:readr/data/enum/page_status.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';

class CommunityController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  final CommunityService _communityService = Get.find<CommunityService>();
  final UserService _userService = Get.find<UserService>();
  final scrollController = ScrollController();

  UserService get userService => _userService;
  bool get isMember => _userService.isMember.value;

  PickableItemController getPickableItemController(String tag) {
    return Get.find<PickableItemController>(tag: tag);
  }

  final RxBool rxIsInitialized = RxBool(false);
  final RxBool rxIsError = RxBool(false);
  final RxnString rxError = RxnString();
  final RxBool rxIsLoadingMore = RxBool(false);
  final RxList<CommunityListItem> rxCommunityList = <CommunityListItem>[].obs;
  final RxBool rxIsNoMore = RxBool(false);
  final Rx<PageStatus> rxPageStatus = Rx<PageStatus>(PageStatus.normal);

  bool get isError => rxIsError.value;
  String? get error => rxError.value;

  int _currentPage = 0;
  static const int _pageSize = 10;

  final RxList<Member> rxRecommendMembers = <Member>[].obs;

  Future<void> _fetchRecommendMembers(List<dynamic> membersJson) async {
    try {
      final members =
          membersJson.map((memberJson) => Member.fromJson(memberJson)).toList();
      rxRecommendMembers.assignAll(members);
    } catch (e) {
      print('Error fetching recommend members: $e');
    }
    return;
  }

  void initPage() async {
    rxPageStatus.value = PageStatus.loading;
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
        rxCommunityList.assignAll(mappedItems);

        if (data.members.isNotEmpty) {
          await _fetchRecommendMembers(data.members);
        }

        _currentPage++;
      }

      rxIsInitialized.value = true;
      rxPageStatus.value = PageStatus.normal;
    } catch (e) {
      rxIsError.value = true;
      rxError.value = e.toString();
      rxPageStatus.value = PageStatus.normal;
    }
  }

  Future<void> updateCommunityPage() async {
    _currentPage = 0;
    rxIsNoMore.value = false;
    try {
      final data = await _communityService.fetchSocialPage(
        memberId: _userService.currentUser.memberId,
        index: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (data != null) {
        rxCommunityList.assignAll(data.stories
            .map((item) => CommunityListItem.fromJson(item))
            .toList());
        _currentPage++;
      }
    } catch (e) {
      print('Error updating community page: $e');
    }
  }

  Future<void> fetchMoreFollowingPickedNews() async {
    if (rxIsLoadingMore.value || rxIsNoMore.value) return;

    rxIsLoadingMore.value = true;
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
        rxCommunityList.addAll(newItems);
        _currentPage++;

        if (newItems.length < _pageSize) {
          rxIsNoMore.value = true;
        }
      } else {
        rxIsNoMore.value = true;
      }
    } finally {
      rxIsLoadingMore.value = false;
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

  List<MemberFollowableItem> getRecommendMemberFollowableItems() {
    return rxRecommendMembers.map((m) => MemberFollowableItem(m)).toList();
  }

  List<CommunityListItem> getHeaderCommunityList() {
    if (rxCommunityList.isEmpty) {
      return [];
    }

    int end = 3;
    if (rxCommunityList.length < 3) {
      end = rxCommunityList.length;
    }

    return rxCommunityList.sublist(0, end);
  }

  List<CommunityListItem> getRemainingCommunityList() {
    if (rxCommunityList.length <= 3) {
      return [];
    }

    return rxCommunityList.sublist(3);
  }

  void handleVisibilityChanged(double visiblePercentage) {
    if (visiblePercentage > 50 && !rxIsLoadingMore.value) {
      fetchMoreFollowingPickedNews();
    }
  }

  Future<void> handleMoreAction(
      BuildContext context, CommunityListItem item) async {
    final info = await getMoreActionSheetInfo(item);
    await showMoreActionSheet(
      context: context,
      objective: info['objective'],
      id: item.itemId,
      controllerTag: item.controllerTag,
      url: info['url'],
      heroImageUrl: item.newsListItem?.heroImageUrl,
      newsListItem: item.newsListItem,
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
