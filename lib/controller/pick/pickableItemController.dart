import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/personalFile/bookmarkTabController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pickIdItem.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';

//controller for pickBar and pickButton
class PickableItemController extends GetxController {
  final PickObjective objective;
  final String targetId;
  final RxInt pickCount = 0.obs;
  final RxInt commentCount = 0.obs;
  final RxBool isPicked = false.obs;
  final pickedMembers = <Member>[].obs;
  final String controllerTag;

  //only for news
  final isBookmarked = false.obs;

  //only for collection
  final RxnString collectionTitle = RxnString();
  final RxnString collectionHeroImageUrl = RxnString();

  PickableItemController({
    required this.objective,
    required this.targetId,
    required this.controllerTag,
    int pickCount = 0,
    int commentCount = 0,
    List<Member>? pickedMembers,
    String? collectionTitle,
    String? collectionHeroImageUrl,
  }) {
    this.pickCount.value = pickCount;
    this.commentCount.value = commentCount;

    if (pickedMembers != null) {
      this.pickedMembers.assignAll(pickedMembers);
    }

    this.collectionTitle.value = collectionTitle;
    this.collectionHeroImageUrl.value = collectionHeroImageUrl;
  }

  @override
  void onReady() {
    isPicked.value = Get.find<PickAndBookmarkService>().pickList.any(
        (element) =>
            element.objective == objective && element.targetId == targetId);
    isBookmarked.value = Get.find<PickAndBookmarkService>().bookmarkList.any(
        (element) =>
            element.objective == objective && element.targetId == targetId);
    super.onReady();
  }

  void addPick() async {
    isPicked.value = true;
    pickCount.value++;

    bool result = await Get.find<PubsubService>().addPick(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: targetId,
      objective: objective,
    );

    PickToast.showPickToast(result, true);

    if (result) {
      Get.find<PickAndBookmarkService>().pickList.add(PickIdItem(
            objective: objective,
            kind: PickKind.read,
            targetId: targetId,
          ));

      if (Get.isRegistered<PersonalFilePageController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<PersonalFilePageController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .pickCount
            .value++;
      }
      _updateOwnPickTab();
    } else {
      isPicked.value = false;
      pickCount.value--;
    }
  }

  void addPickAndComment(String commentContent) async {
    isPicked.value = true;
    pickCount.value++;
    commentCount.value++;

    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      final commentController = Get.find<CommentController>(tag: controllerTag);
      commentController.commentSending(commentContent);
    }

    bool result = await Get.find<PubsubService>().pickAndComment(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: targetId,
      objective: objective,
      commentContent: commentContent,
    );

    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      final commentController = Get.find<CommentController>(tag: controllerTag);
      if (result) {
        result = await commentController
            .commentSendFinish(commentController.sendingComment!);
      } else {
        commentController.commentSendFailed();
      }
    }

    PickToast.showPickToast(result, true);

    if (result) {
      if (Get.isRegistered<PersonalFilePageController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<PersonalFilePageController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .pickCount
            .value++;
      }
      _updateOwnPickTab();
      await Future.delayed(const Duration(seconds: 5));
      Get.find<PickAndBookmarkService>().fetchPickIds();
    } else {
      isPicked.value = false;
      pickCount.value--;
    }
  }

  void deletePick() async {
    isPicked.value = false;
    pickCount.value--;

    String? myPickCommentId = Get.find<PickAndBookmarkService>()
        .pickList
        .firstWhereOrNull((element) =>
            element.objective == objective && element.targetId == targetId)
        ?.myPickCommentId;
    if (myPickCommentId != null) {
      commentCount.value--;
    }

    bool isSuccess = await Get.find<PubsubService>().unPick(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: targetId,
      objective: objective,
    );

    if (isSuccess) {
      if (Get.isRegistered<CommentController>(tag: controllerTag) &&
          myPickCommentId != null) {
        Get.find<CommentController>(tag: controllerTag)
            .deletePickComment(myPickCommentId);
      }
      Get.find<PickAndBookmarkService>().pickList.removeWhere((element) =>
          element.objective == objective && element.targetId == targetId);
      if (Get.isRegistered<PersonalFilePageController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<PersonalFilePageController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .pickCount
            .value--;
      }
      _updateOwnPickTab();
    } else {
      pickCount.value++;
      if (myPickCommentId != null) {
        commentCount.value++;
      }
      isPicked.value = true;
    }
    PickToast.showPickToast(isSuccess, false);
  }

  Future<void> _updateOwnPickTab() async {
    //update own personal file pick tab if exists
    if (Get.isRegistered<PickTabController>(
        tag: Get.find<UserService>().currentUser.memberId)) {
      EasyDebounce.debounce(
        '_updateOwnPickTab',
        const Duration(seconds: 2),
        () {
          Get.find<PickTabController>(
                  tag: Get.find<UserService>().currentUser.memberId)
              .fetchPickList();
        },
      );
    }
  }

  Future<void> updateBookmark() async {
    bool result = false;
    if (isBookmarked.isTrue) {
      result = await Get.find<PubsubService>().addBookmark(
        memberId: Get.find<UserService>().currentUser.memberId,
        storyId: targetId,
      );
      PickToast.showBookmarkToast(result, true);
      if (!result) {
        isBookmarked(false);
      } else {
        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          final ownPersonalFileController =
              Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId);

          ownPersonalFileController.bookmarkCount.value++;
        }

        Get.find<PickAndBookmarkService>().bookmarkList.add(PickIdItem(
              objective: objective,
              kind: PickKind.bookmark,
              targetId: targetId,
            ));

        if (Get.isRegistered<BookmarkTabController>()) {
          await Future.delayed(const Duration(seconds: 2));
          Get.find<BookmarkTabController>().fetchBookmark();
        }
      }
    } else {
      result = await Get.find<PubsubService>().removeBookmark(
        memberId: Get.find<UserService>().currentUser.memberId,
        storyId: targetId,
      );
      PickToast.showBookmarkToast(result, false);
      if (!result) {
        isBookmarked(true);
      } else {
        if (Get.isRegistered<BookmarkTabController>()) {
          Get.find<BookmarkTabController>()
              .bookmarkList
              .removeWhere((element) => element.story?.id == targetId);
        }

        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          final ownPersonalFileController =
              Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId);

          ownPersonalFileController.bookmarkCount.value > 0
              ? ownPersonalFileController.bookmarkCount.value--
              : ownPersonalFileController.bookmarkCount.value = 0;
        }

        Get.find<PickAndBookmarkService>().bookmarkList.removeWhere((element) =>
            element.objective == objective && element.targetId == targetId);
      }
    }
  }
}
