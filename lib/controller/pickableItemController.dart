import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/services/pickService.dart';

//controller for pickBar and pickButton
class PickableItemController extends GetxController {
  final PickRepos pickRepos;
  final PickObjective objective;
  final String targetId;
  late final RxnString myPickId;
  late final RxnString myPickCommentId;
  late final RxInt pickCount;
  late final RxInt commentCount;
  late final RxBool isPicked;
  final pickedMembers = <Member>[].obs;
  final isLoading = false.obs;
  final String controllerTag;

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
  }) {
    this.pickCount = pickCount.obs;
    this.commentCount = commentCount.obs;
    this.myPickId = RxnString(myPickId);
    this.myPickCommentId = RxnString(myPickCommentId);
    if (myPickId != null) {
      isPicked = true.obs;
    } else {
      isPicked = false.obs;
    }

    if (pickedMembers != null) {
      this.pickedMembers.assignAll(pickedMembers);
    }
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
