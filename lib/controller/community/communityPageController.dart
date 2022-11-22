import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/services/communityService.dart';

class CommunityPageController extends GetxController {
  final CommunityRepos repository;
  CommunityPageController(this.repository);

  final communityList = <CommunityListItem>[].obs;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;
  bool _noMorePicked = false;
  bool _noMoreComment = false;
  bool _noMoreNewCollection = false;
  final List<String> fetchedStoryIds = [];
  final List<String> fetchedCollectionIds = [];

  bool isInitialized = false;
  bool isError = false;
  dynamic error;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    ever<bool>(Get.find<UserService>().isMember, (callback) {
      if (Get.find<RootPageController>().tabIndex.value == 0) {
        initPage();
      }
    });
    super.onInit();
  }

  void initPage() async {
    isInitialized = false;
    isError = false;
    update();
    await Future.wait([
      fetchFollowingStoryAndCollection().then((value) => isError = !value),
      Get.find<RecommendMemberBlockController>().fetchRecommendMembers(),
    ]);
    await Get.find<PickAndBookmarkService>().fetchPickIds();
    isInitialized = true;
    update();
  }

  Future<bool> fetchFollowingStoryAndCollection() async {
    try {
      List<CommunityListItem> pickedList =
          await repository.fetchFollowingPicked();
      _updateIdList(pickedList, cleanList: true);
      if (pickedList.length < 10 && pickedList.isNotEmpty) {
        List<CommunityListItem> additionalList =
            await repository.fetchFollowingPicked(
          alreadyFetchCollectionIds: fetchedCollectionIds,
          alreadyFetchStoryIds: fetchedStoryIds,
        );
        pickedList.addAll(additionalList);
        if (additionalList.length < 20) {
          _noMorePicked = true;
        }
        _updateIdList(pickedList, cleanList: true);
      } else if (pickedList.isEmpty) {
        _noMorePicked = true;
      }

      List<CommunityListItem> commentList = [];
      List<CommunityListItem> newCollectionList = [];

      await Future.wait([
        repository
            .fetchFollowingComment(
          alreadyFetchCollectionIds: fetchedCollectionIds,
          alreadyFetchStoryIds: fetchedStoryIds,
        )
            .then((value) {
          commentList = value;
          if (commentList.length < 20) {
            _noMoreComment = true;
          }
          pickedList.addAll(commentList);
        }),
        repository.fetchCollections().then((value) {
          newCollectionList = value;
          if (newCollectionList.length < 20) {
            _noMoreNewCollection = true;
          }
          pickedList.addAll(newCollectionList);
        }),
      ]);

      //sort again after combined to one list
      pickedList.sort((a, b) => b.orderByTime.compareTo(a.orderByTime));
      communityList.assignAll(pickedList);
      isNoMore.value = _noMorePicked && _noMoreComment && _noMoreNewCollection;
      _updateIdList(commentList);
      return true;
    } catch (e) {
      print('Fetch following picked news error: $e');
      error = determineException(e);
      return false;
    }
  }

  //call when user tap button in bottomNavigationBar
  void scrollToTopAndRefresh() async {
    if (isInitialized) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(microseconds: 100));
        return !scrollController.hasClients;
      });
      await Future.wait([
        scrollController.animateTo(0,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn),
        updateCommunityPage()
      ]);
    }
  }

  Future<void> updateCommunityPage() async {
    await Future.wait([
      fetchFollowingStoryAndCollection(),
      Get.find<RecommendMemberBlockController>().fetchRecommendMembers(),
    ]);
    await Get.find<PickAndBookmarkService>().fetchPickIds();
  }

  void _updateIdList(List<CommunityListItem> communityList,
      {bool cleanList = false}) {
    if (cleanList) {
      fetchedStoryIds.clear();
      fetchedCollectionIds.clear();
    }
    for (var item in communityList) {
      if (item.newsListItem != null) {
        fetchedStoryIds.add(item.newsListItem!.id);
      } else if (item.collection != null) {
        fetchedCollectionIds.add(item.collection!.id);
      }
    }
  }

  void fetchMoreFollowingPickedNews() async {
    try {
      isLoadingMore.value = true;
      List<CommunityListItem> newPickedList =
          await repository.fetchFollowingPicked(
        alreadyFetchCollectionIds: fetchedCollectionIds,
        alreadyFetchStoryIds: fetchedStoryIds,
      );
      _updateIdList(newPickedList);
      if (newPickedList.length < 20) {
        _noMorePicked = true;
      }

      List<CommunityListItem> newCommentList = [];
      List<CommunityListItem> newCollectionList = [];

      await Future.wait([
        repository
            .fetchFollowingComment(
          alreadyFetchCollectionIds: fetchedCollectionIds,
          alreadyFetchStoryIds: fetchedStoryIds,
        )
            .then((value) {
          newCommentList = value;
          if (newCommentList.length < 20) {
            _noMoreComment = true;
          }
        }),
        repository.fetchCollections().then((value) {
          newCollectionList = value;
          if (newCollectionList.length < 20) {
            _noMoreNewCollection = true;
          }
        }),
        Get.find<PickAndBookmarkService>().fetchPickIds(),
      ]);

      newPickedList.addAll(newCommentList);
      newPickedList.addAll(newCollectionList);
      //sort again after combined to one list
      newPickedList.sort((a, b) => b.orderByTime.compareTo(a.orderByTime));
      communityList.addAll(newPickedList);
      isNoMore.value = _noMorePicked && _noMoreComment && _noMoreNewCollection;
      _updateIdList(newCommentList);
    } catch (e) {
      print('Fetch more following picked news error: $e');
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
