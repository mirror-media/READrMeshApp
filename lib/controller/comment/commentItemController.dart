import 'package:get/get.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/commentService.dart';

class CommentItemController extends GetxController {
  final CommentRepos commentRepos;
  final RxString commentContent = ''.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  late final String? commentId;
  final RxBool isEdited = false.obs;
  Comment comment;
  final isSending = false.obs;
  final isMyNewComment = false.obs;
  final isExpanded = false.obs;

  CommentItemController({
    required this.commentRepos,
    required this.comment,
  });

  @override
  void onInit() {
    super.onInit();
    commentContent(comment.content);
    isLiked(comment.isLiked);
    likeCount(comment.likedCount);
    commentId = comment.id;
    isEdited(comment.isEdited);
    debounce<bool>(
      isLiked,
      (callback) {
        if (callback) {
          addLike();
        } else {
          removeLike();
        }
      },
      time: const Duration(seconds: 1),
    );
  }

  void addLike() async {
    bool result = await Get.find<PubsubService>().addLike(
      commentId: comment.id,
      memberId: Get.find<UserService>().currentUser.memberId,
    );
    if (!result) {
      isLiked(false);
      likeCount.value--;
    }
  }

  void removeLike() async {
    bool result = await Get.find<PubsubService>().removeLike(
      commentId: comment.id,
      memberId: Get.find<UserService>().currentUser.memberId,
    );
    if (!result) {
      isLiked(true);
      likeCount.value++;
    }
  }

  void editComment(Comment newComment) async {
    String oldContent = commentContent.value;
    commentContent.value = newComment.content;
    isEdited.value = true;
    bool result = await Get.find<PubsubService>().editComment(
        commentId: newComment.id,
        newContent: newComment.content,
        memberId: Get.find<UserService>().currentUser.memberId);
    if (!result) {
      commentContent.value = oldContent;
      isEdited.value = comment.isEdited;
    } else {
      comment = newComment;
    }
  }
}
