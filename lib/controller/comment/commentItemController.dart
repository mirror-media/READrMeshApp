import 'package:get/get.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/commentService.dart';

class CommentItemController extends GetxController {
  final CommentRepos commentRepos;
  final RxString commentContent = ''.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  late final String commentId;
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
    int? newLikeCount = await commentRepos.addLike(
      commentId: commentId,
    );
    if (newLikeCount != null) {
      likeCount.value = newLikeCount;
    } else {
      isLiked(false);
      likeCount.value--;
    }
  }

  void removeLike() async {
    int? newLikeCount = await commentRepos.removeLike(
      commentId: commentId,
    );
    if (newLikeCount != null) {
      likeCount.value = newLikeCount;
    } else {
      isLiked(true);
      likeCount.value++;
    }
  }

  void editComment(Comment newComment) async {
    String oldContent = commentContent.value;
    commentContent.value = newComment.content;
    isEdited.value = true;
    bool result = await commentRepos.editComment(newComment);
    if (!result) {
      commentContent.value = oldContent;
      isEdited.value = comment.isEdited;
    } else {
      comment = newComment;
    }
  }

  void updateComment(Comment newComment) {
    comment = newComment;
    commentContent(comment.content);
    isLiked(comment.isLiked);
    likeCount(comment.likedCount);
    isEdited(comment.isEdited);
  }
}
