import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/commentService.dart';

//controller for comments in popup dialog and bottom card
class CommentController extends GetxController {
  final CommentRepos commentRepos;
  final PickObjective objective;
  final String id;
  final allComments = <Comment>[].obs;
  final popularComments = <Comment>[].obs;
  final sendingComment = Rxn<Comment>();
  final isLoading = false.obs;
  final isSending = false.obs;
  final String controllerTag;
  late final PickableItemController pickableItemController;
  final bool isPickTab;

  CommentController({
    required this.commentRepos,
    required this.objective,
    required this.id,
    required this.controllerTag,
    this.isPickTab = false,
    List<Comment>? allComments,
    List<Comment>? popularComments,
  }) {
    if (allComments != null) {
      this.allComments.assignAll(allComments);
    }

    if (popularComments != null) {
      this.popularComments.assignAll(popularComments);
    }

    pickableItemController =
        Get.find<PickableItemController>(tag: controllerTag);
  }

  void fetchComments() async {
    isLoading.value = true;
    List<Comment>? allFetchComments;
    try {
      if (objective == PickObjective.story) {
        allFetchComments = await commentRepos.fetchCommentsByStoryId(id);
      } else {
        allFetchComments = await commentRepos.fetchCommentsByCollectionId(id);
      }

      if (allFetchComments != null) {
        allComments.assignAll(allFetchComments);
        isLoading.value = false;
      } else {
        throw Exception('Server return error');
      }
    } catch (e) {
      print('Fetch comments error: $e');
      Fluttertoast.showToast(
        msg: "發生錯誤 請稍後再試一次",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Get.back();
    }
  }

  Future<bool> addComment(String commentContent) async {
    commentSending(commentContent);
    List<Comment>? newAllComments = await commentRepos.createComment(
      targetId: id,
      content: commentContent,
      objective: objective,
      state: CommentTransparency.public,
    );

    if (newAllComments != null) {
      // check new comment is first
      if (newAllComments.first.member.memberId !=
              Get.find<UserService>().currentUser.memberId &&
          newAllComments.first.content != commentContent) {
        int index = newAllComments.indexWhere((element) =>
            element.member.memberId ==
                Get.find<UserService>().currentUser.memberId &&
            element.content == commentContent);
        if (index == -1) {
          newAllComments = null;
        } else {
          Comment myNewComment = newAllComments[index];
          newAllComments.removeAt(index);
          newAllComments.insert(0, myNewComment);
        }
      }
    }

    if (newAllComments == null) {
      Fluttertoast.showToast(
        msg: "留言失敗，請稍後再試一次",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      commentSendFailed();
    } else {
      commentSendSuccess(newAllComments.first);
      allComments.assignAll(newAllComments);
      pickableItemController.commentCount.value = allComments.length;
      _updatePopularCommentList();
    }

    return newAllComments != null;
  }

  void commentSending(String commentContent) {
    isSending.value = true;
    sendingComment(Comment(
      id: 'Sending',
      member: Get.find<UserService>().currentUser,
      content: commentContent,
      state: "public",
      publishDate: DateTime.now(),
    ));
    final tempCommentItemController = Get.put(
      CommentItemController(
          commentRepos: CommentService(), comment: sendingComment.value!),
      tag: 'CommentSending',
    );
    tempCommentItemController.isSending(true);
    allComments.insert(0, sendingComment.value!);
  }

  void commentSendSuccess(Comment newComment) {
    final commentItemController = Get.put(
      CommentItemController(
          commentRepos: CommentService(), comment: newComment),
      tag: 'Comment${newComment.id}',
    );
    commentItemController.isSending(false);
    commentItemController.isMyNewComment(true);
    allComments.removeAt(0);
    allComments.insert(0, newComment);
    isSending.value = false;
    sendingComment.value = null;
    Get.delete<CommentItemController>(tag: 'CommentSending');
  }

  void commentSendFailed() {
    sendingComment.value = null;
    allComments.removeAt(0);
    isSending.value = false;
    Get.delete<CommentItemController>(tag: 'CommentSending');
  }

  void deletePickComment(String commentId) {
    allComments.removeWhere((element) => element.id == commentId);
    _updatePopularCommentList();
  }

  void deleteComment(String commentId) async {
    int allCommentIndex =
        allComments.indexWhere((element) => element.id == commentId);
    Comment backupComment = allComments[allCommentIndex];
    allComments.removeAt(allCommentIndex);
    pickableItemController.commentCount.value = allComments.length;

    int popularCommentIndex =
        popularComments.indexWhere((element) => element.id == commentId);
    if (popularCommentIndex != -1) {
      _updatePopularCommentList();
    }

    bool result = await commentRepos.deleteComment(commentId);

    if (!result) {
      allComments.insert(allCommentIndex, backupComment);
      if (popularCommentIndex != -1) {
        _updatePopularCommentList();
      }
      pickableItemController.commentCount.value = allComments.length;
    }
  }

  //update popular comments
  void _updatePopularCommentList() {
    popularComments.clear();
    List<Comment> tempList = [];
    tempList.addAll(allComments);
    tempList.sort((a, b) => b.likedCount.compareTo(a.likedCount));
    for (int i = 0; i < tempList.length && i < 3; i++) {
      if (tempList[i].likedCount > 0) {
        popularComments.add(tempList[i]);
      }
    }
  }
}
