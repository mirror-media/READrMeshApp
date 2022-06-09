import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
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
  final RxnString myPickId = RxnString();
  final RxnString myPickCommentId = RxnString();
  final RxInt pickCount = 0.obs;
  final RxInt commentCount = 0.obs;
  final RxBool isPicked = false.obs;
  final pickedMembers = <Member>[].obs;
  final isLoading = false.obs;
  final String controllerTag;

  //just for collection
  final RxnString collectionTitle = RxnString();
  final RxnString collectionHeroImageUrl = RxnString();

  PickableItemController({
    required this.pickRepos,
    required this.objective,
    required this.targetId,
    required this.controllerTag,
    String? myPickId,
    String? myPickCommentId,
    int pickCount = 0,
    int commentCount = 0,
    List<Member>? pickedMembers,
    String? collectionTitle,
    String? collectionHeroImageUrl,
  }) {
    this.pickCount.value = pickCount;
    this.commentCount.value = commentCount;
    this.myPickId.value = myPickId;
    this.myPickCommentId.value = myPickCommentId;
    if (myPickId != null) {
      isPicked.value = true;
    }

    if (pickedMembers != null) {
      this.pickedMembers.assignAll(pickedMembers);
    }

    this.collectionTitle.value = collectionTitle;
    this.collectionHeroImageUrl.value = collectionHeroImageUrl;
  }

  @override
  void onInit() {
    super.onInit();
    ever<String?>(myPickId, (value) {
      if (value == null) {
        isPicked.value = false;
      } else {
        isPicked.value = true;
      }
    });
  }

  void addPick() async {
    isLoading(true);
    isPicked.value = true;
    pickCount.value++;

    myPickId.value = await pickRepos
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

    if (myPickId.value == null) {
      pickCount.value--;
      isPicked.value = false;
    } else {
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

    PickToast.showPickToast(myPickId.value != null, true);

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

    if (result != null) {
      myPickId.value = result['pickId'];
      myPickCommentId.value = result['pickComment'].id;
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
    } else {
      pickCount.value--;
      commentCount.value--;
      isPicked.value = false;
    }

    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      final commentController = Get.find<CommentController>(tag: controllerTag);
      if (result != null) {
        commentController.commentSendSuccess(result['pickComment']);
      } else {
        commentController.commentSendFailed();
      }
    }
    PickToast.showPickToast(result != null, true);

    isLoading(false);
  }

  void deletePick() async {
    isLoading(true);
    isPicked.value = false;
    pickCount.value--;

    bool isSuccess = false;
    if (myPickCommentId.value != null) {
      commentCount.value--;
      isSuccess = await pickRepos
          .deletePickAndComment(myPickId.value!, myPickCommentId.value!)
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () => false,
          );
    } else {
      isSuccess = await pickRepos.deletePick(myPickId.value!).timeout(
            const Duration(seconds: 90),
            onTimeout: () => false,
          );
    }

    if (isSuccess) {
      if (Get.isRegistered<CommentController>(tag: controllerTag)) {
        Get.find<CommentController>(tag: controllerTag)
            .deletePickComment(myPickCommentId.value!);
      }
      myPickId.value = null;
      myPickCommentId.value = null;
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
    } else {
      pickCount.value++;
      if (myPickCommentId.value != null) {
        commentCount.value++;
      }
      isPicked.value = true;
    }
    PickToast.showPickToast(isSuccess, false);

    isLoading(false);
  }
}
