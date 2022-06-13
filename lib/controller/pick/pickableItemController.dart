import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/personalFile/bookmarkTabController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/services/pickService.dart';

//controller for pickBar and pickButton
class PickableItemController extends GetxController {
  final PickRepos pickRepos;
  final PickObjective objective;
  final String targetId;
  final RxInt pickCount = 0.obs;
  final RxInt commentCount = 0.obs;
  final RxBool isPicked = false.obs;
  final pickedMembers = <Member>[].obs;
  final isLoading = false.obs;
  final String controllerTag;

  //just for news
  final isBookmarked = false.obs;

  //just for collection
  final RxnString collectionTitle = RxnString();
  final RxnString collectionHeroImageUrl = RxnString();

  PickableItemController({
    required this.pickRepos,
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

  void addPick() async {
    isLoading(true);
    isPicked.value = true;
    pickCount.value++;

    await pickRepos
        .createPick(
          targetId: targetId,
          objective: objective,
          state: PickState.public,
          kind: PickKind.read,
        )
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () => null,
        );

    await _updatePagesAndData();

    PickToast.showPickToast(true, true);

    isLoading(false);
  }

  void addPickAndComment(String comment) async {
    isLoading(true);
    isPicked.value = true;
    pickCount.value++;
    commentCount.value++;

    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      final commentController = Get.find<CommentController>(tag: controllerTag);
      commentController.commentSending(comment);
    }

    var result = await pickRepos
        .createPickAndComment(
          targetId: targetId,
          objective: objective,
          state: PickState.public,
          kind: PickKind.read,
          commentContent: comment,
        )
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () => null,
        );

    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      final commentController = Get.find<CommentController>(tag: controllerTag);
      if (result != null) {
        commentController.commentSendSuccess(result['pickComment']);
      } else {
        commentController.commentSendFailed();
      }
    }

    await _updatePagesAndData();
    PickToast.showPickToast(true, true);

    isLoading(false);
  }

  void deletePick() async {
    isLoading(true);
    isPicked.value = false;
    pickCount.value--;

    bool isSuccess = false;
    String? myPickId = Get.find<PickAndBookmarkService>()
        .pickList
        .firstWhereOrNull((element) =>
            element.objective == objective && element.targetId == targetId)
        ?.myPickId;
    String? myPickCommentId = Get.find<PickAndBookmarkService>()
        .pickList
        .firstWhereOrNull((element) =>
            element.objective == objective && element.targetId == targetId)
        ?.myPickCommentId;
    if (myPickId != null && myPickCommentId != null) {
      commentCount.value--;
      isSuccess = await pickRepos
          .deletePickAndComment(myPickId, myPickCommentId)
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () => false,
          );
    } else if (myPickId != null) {
      isSuccess = await pickRepos.deletePick(myPickId).timeout(
            const Duration(seconds: 90),
            onTimeout: () => false,
          );
    }

    if (isSuccess) {
      if (Get.isRegistered<CommentController>(tag: controllerTag) &&
          myPickCommentId != null) {
        Get.find<CommentController>(tag: controllerTag)
            .deletePickComment(myPickCommentId);
      }
    } else {
      pickCount.value++;
      if (myPickCommentId != null) {
        commentCount.value++;
      }
      isPicked.value = true;
    }
    await Future.delayed(const Duration(seconds: 2));
    await _updatePagesAndData();
    PickToast.showPickToast(isSuccess, false);

    isLoading(false);
  }

  Future<void> _updatePagesAndData() async {
    await Future.delayed(const Duration(seconds: 2));
    await Get.find<PickAndBookmarkService>().fetchPickIds();
    //update own personal file if exists
    if (Get.isRegistered<PersonalFilePageController>(
        tag: Get.find<UserService>().currentUser.memberId)) {
      Get.find<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId)
          .fetchMemberData();
    }

    //update own personal file pick tab if exists
    if (Get.isRegistered<PickTabController>(
        tag: Get.find<UserService>().currentUser.memberId)) {
      Get.find<PickTabController>(
              tag: Get.find<UserService>().currentUser.memberId)
          .fetchPickList();
    }
  }

  Future<void> updateBookmark() async {
    String? bookmarkId = Get.find<PickAndBookmarkService>()
        .bookmarkList
        .firstWhereOrNull((element) =>
            element.objective == objective && element.targetId == targetId)
        ?.myBookmarkId;
    if (isBookmarked.isTrue && bookmarkId == null) {
      bookmarkId = await pickRepos.createPick(
        targetId: targetId,
        objective: PickObjective.story,
        state: PickState.private,
        kind: PickKind.bookmark,
      );
      PickToast.showBookmarkToast(bookmarkId != null, true);
      if (bookmarkId == null) {
        isBookmarked(false);
      } else {
        if (Get.isRegistered<BookmarkTabController>()) {
          Get.find<BookmarkTabController>().fetchBookmark();
        }

        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          final ownPersonalFileController =
              Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId);

          ownPersonalFileController.bookmarkCount.value++;
        }
      }
    } else if (isBookmarked.isFalse && bookmarkId != null) {
      bool isDelete = await pickRepos.deletePick(bookmarkId);
      PickToast.showBookmarkToast(isDelete, false);
      if (!isDelete) {
        isBookmarked(true);
      } else {
        if (Get.isRegistered<BookmarkTabController>()) {
          Get.find<BookmarkTabController>()
              .bookmarkList
              .removeWhere((element) => element.id == bookmarkId);
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
        bookmarkId = null;
      }
    }
    await Future.delayed(const Duration(seconds: 2));
    await Get.find<PickAndBookmarkService>().fetchPickIds();
  }
}
