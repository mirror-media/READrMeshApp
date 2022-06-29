import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/pubsubService.dart';
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
  final isLoading = false.obs;
  final isSending = false.obs;
  final String controllerTag;
  late final PickableItemController pickableItemController;
  final bool isPickTab;
  Comment? sendingComment;

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
    List<Comment>? allFetchComments = await _fetchCommentsById();
    if (allFetchComments != null) {
      allComments.assignAll(allFetchComments);
      isLoading.value = false;
    } else {
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
    return await Get.find<PubsubService>()
        .addComment(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: id,
      objective: objective,
      commentContent: commentContent,
    )
        .then((value) async {
      bool isSuccess = value;
      if (value) {
        isSuccess = await commentSendFinish(sendingComment!);
      } else {
        commentSendFailed();
      }

      if (isSuccess) {
        pickableItemController.commentCount.value = allComments.length;
        _updatePopularCommentList();
      } else {
        Fluttertoast.showToast(
          msg: "留言失敗，請稍後再試一次",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      return isSuccess;
    });
  }

  void commentSending(String commentContent) {
    isSending.value = true;
    sendingComment = Comment(
      id: DateTime.now().toString(),
      member: Get.find<UserService>().currentUser,
      content: commentContent,
      state: "public",
      publishDate: DateTime.now(),
    );
    final tempCommentItemController = Get.put(
      CommentItemController(
          commentRepos: CommentService(), comment: sendingComment!),
      tag: sendingComment?.id,
    );
    tempCommentItemController.isSending(true);
    allComments.insert(0, sendingComment!);
  }

  Future<bool> commentSendFinish(Comment newSendingComment) async {
    int retryCount = 0;
    do {
      await Future.delayed(Duration(seconds: 1 + retryCount));
      List<Comment>? allFetchComments = await _fetchCommentsById();
      if (allFetchComments != null) {
        Comment? newFetchComment = allFetchComments.firstWhereOrNull(
            (element) =>
                element.content == newSendingComment.content &&
                element.member.memberId == newSendingComment.member.memberId);

        if (newFetchComment != null) {
          final commentItemController = Get.put(
            CommentItemController(
                commentRepos: CommentService(), comment: newFetchComment),
            tag: newFetchComment.id,
          );
          allComments.assignAll(allFetchComments);
          commentItemController.isSending(false);
          commentItemController.isMyNewComment(true);
          Get.delete<CommentItemController>(tag: newSendingComment.id);
          isSending.value = false;
          sendingComment = null;
          break;
        }
      }
      retryCount++;
    } while (retryCount < 5);

    if (retryCount >= 5) {
      commentSendFailed();
      return false;
    } else {
      return true;
    }
  }

  void commentSendFailed() {
    String sendingCommentId = allComments[0].id;
    allComments.removeAt(0);
    isSending.value = false;
    Get.delete<CommentItemController>(tag: sendingCommentId);
    sendingComment = null;
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

    bool result = false;
    if (int.tryParse(commentId) != null) {
      result =
          await Get.find<PubsubService>().removeComment(commentId: commentId);
      if (!result) {
        allComments.insert(allCommentIndex, backupComment);
        if (popularCommentIndex != -1) {
          _updatePopularCommentList();
        }
        pickableItemController.commentCount.value = allComments.length;
      }
    } else {
      Fluttertoast.showToast(
        msg: "發生錯誤 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      List<Comment>? allFetchComments = await _fetchCommentsById();
      if (allFetchComments != null) {
        allComments.assignAll(allFetchComments);
        _updatePopularCommentList();
      }
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

  Future<List<Comment>?> _fetchCommentsById() async {
    try {
      if (objective == PickObjective.story) {
        return await commentRepos.fetchCommentsByStoryId(id);
      } else {
        return await commentRepos.fetchCommentsByCollectionId(id);
      }
    } catch (e) {
      print('Fetch comments error: $e');
      return null;
    }
  }
}
