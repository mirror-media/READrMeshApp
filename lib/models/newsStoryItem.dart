import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/pickService.dart';

class NewsStoryItem {
  final String id;
  final String title;
  final Publisher source;
  final List<Member> followingPickMembers;
  final List<Member> otherPickMembers;
  final List<Comment> popularComments;
  final List<Comment> allComments;
  int pickCount;
  String? myPickId;
  String? myPickCommentId;
  String? bookmarkId;
  final String? content;
  final String? writer;
  final String controllerTag;

  NewsStoryItem({
    required this.id,
    required this.title,
    required this.source,
    required this.followingPickMembers,
    required this.otherPickMembers,
    required this.popularComments,
    required this.allComments,
    required this.controllerTag,
    this.pickCount = 0,
    this.myPickId,
    this.bookmarkId,
    this.content,
    this.writer,
    this.myPickCommentId,
  });

  factory NewsStoryItem.fromJson(Map<String, dynamic> json) {
    late Publisher source;
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    List<Comment> allComments = [];
    List<Comment> popularComments = [];
    String? myPickId;
    int pickCount = 0;
    String? bookmarkId;
    bool fullContent = false;
    String? writer;
    String? myPickCommentId;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['followingPickMembers']) &&
        json['followingPickMembers'].isNotEmpty) {
      for (var pick in json['followingPickMembers']) {
        followingPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherPickMembers']) &&
        json['otherPickMembers'].isNotEmpty) {
      for (var pick in json['otherPickMembers']) {
        otherPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['comment']) &&
        json['comment'].isNotEmpty) {
      for (var comment in json['comment']) {
        allComments.add(Comment.fromJson(comment));
      }
      popularComments.addAll(allComments);
      popularComments.sort((a, b) => b.likedCount.compareTo(a.likedCount));
      popularComments.take(3);
      popularComments.removeWhere((element) => element.likedCount == 0);
    }

    if (BaseModel.checkJsonKeys(json, ['pickCount'])) {
      pickCount = json['pickCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['myPickId'])) {
      if (json['myPickId'].isNotEmpty) {
        myPickId = json['myPickId'][0]['id'];
        if (json['myPickId'][0]['pick_comment'].isNotEmpty) {
          myPickCommentId = json['myPickId'][0]['pick_comment'][0]['id'];
        }
      }
    }

    if (BaseModel.checkJsonKeys(json, ['bookmarkId']) &&
        json['bookmarkId'].isNotEmpty) {
      bookmarkId = json['bookmarkId'][0]['id'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_content'])) {
      fullContent = json['full_content'];
    }

    String? content;
    if (BaseModel.hasKey(json, 'content') && fullContent) {
      content = json["content"];
    }

    if (BaseModel.checkJsonKeys(json, ['writer'])) {
      writer = json['writer'];
    }

    List<Member> allPickedMember = [];
    allPickedMember.addAll(followingPickMembers);
    allPickedMember.addAll(otherPickMembers);
    if (Get.isPrepared<PickableItemController>(tag: 'News${json['id']}')) {
      final controller =
          Get.find<PickableItemController>(tag: 'News${json['id']}');
      controller.myPickId.value = myPickId;
      controller.myPickCommentId.value = myPickCommentId;
      controller.pickCount.value = pickCount;
      controller.commentCount.value = allComments.length;
      controller.pickedMembers.assignAll(allPickedMember);
    } else {
      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: json["id"],
          pickRepos: PickService(),
          objective: PickObjective.story,
          myPickId: myPickId,
          myPickCommentId: myPickCommentId,
          pickCount: pickCount,
          commentCount: allComments.length,
          pickedMembers: allPickedMember,
          controllerTag: 'News${json['id']}',
        ),
        tag: 'News${json['id']}',
        fenix: false,
      );
    }

    return NewsStoryItem(
      id: json['id'],
      title: json['title'],
      controllerTag: 'News${json['id']}',
      source: source,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      popularComments: popularComments,
      allComments: allComments,
      myPickId: myPickId,
      pickCount: pickCount,
      bookmarkId: bookmarkId,
      content: content,
      writer: writer,
      myPickCommentId: myPickCommentId,
    );
  }
}
