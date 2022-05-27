import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/pickService.dart';

class NewsListItem {
  final String id;
  final String title;
  final String url;
  final String? summary;
  final String? content;
  final Publisher source;
  final Category? category;
  final DateTime publishedDate;
  final String? heroImageUrl;
  int pickCount;
  int commentCount;
  final bool payWall;
  final bool fullScreenAd;
  final bool fullContent;
  final List<Member> followingPickMembers;
  final List<Member> otherPickMembers;
  final Comment? showComment;
  String? myPickId;
  String? myPickCommentId;
  final DateTime? latestPickTime;
  final String controllerTag;

  NewsListItem({
    required this.id,
    required this.title,
    required this.url,
    this.summary,
    this.content,
    required this.source,
    this.category,
    required this.publishedDate,
    required this.heroImageUrl,
    this.payWall = false,
    this.fullScreenAd = false,
    this.pickCount = 0,
    this.commentCount = 0,
    this.fullContent = false,
    required this.followingPickMembers,
    required this.otherPickMembers,
    this.showComment,
    this.myPickId,
    this.myPickCommentId,
    this.latestPickTime,
    required this.controllerTag,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    late Publisher source;
    Category? category;
    bool payWall = false;
    bool fullContent = false;
    bool fullScreenAd = false;
    int pickCount = 0;
    int commentCount = 0;
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    Comment? showComment;
    List<Comment> allComments = [];
    String? myPickId;
    DateTime? latestPickTime;
    String? content;
    String? myPickCommentId;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['category'])) {
      category = Category.fromNewProductJson(json['category']);
    }

    if (BaseModel.checkJsonKeys(json, ['paywall'])) {
      payWall = json['paywall'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_content'])) {
      fullContent = json['full_content'];
    }

    if (BaseModel.checkJsonKeys(json, ['pickCount'])) {
      pickCount = json['pickCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['commentCount'])) {
      commentCount = json['commentCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['followingPicks']) &&
        json['followingPicks'].isNotEmpty) {
      for (var pick in json['followingPicks']) {
        followingPickMembers.add(Member.fromJson(pick['member']));
      }
      if (json["followingPicks"][0]['picked_date'] != null) {
        latestPickTime =
            DateTime.parse(json["followingPicks"][0]['picked_date']).toLocal();
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherPicks']) &&
        json['otherPicks'].isNotEmpty) {
      for (var pick in json['otherPicks']) {
        otherPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['followingPickComment']) &&
        json['followingPickComment'].isNotEmpty) {
      var pickComment = json['followingPickComment'][0];
      if (BaseModel.checkJsonKeys(pickComment, ['pick_comment']) &&
          pickComment['pick_comment'].isNotEmpty) {
        showComment = Comment.fromJson(pickComment['pick_comment'][0]);
      }
    }

    if (BaseModel.checkJsonKeys(json, ['notFollowingComment']) &&
        json['notFollowingComment'].isNotEmpty) {
      showComment = Comment.fromJson(json['notFollowingComment'][0]);
    }

    if (BaseModel.checkJsonKeys(json, ['allComments']) &&
        json['allComments'].isNotEmpty) {
      for (var comment in json['allComments']) {
        allComments.add(Comment.fromJson(comment));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['myPickId'])) {
      if (json['myPickId'].isNotEmpty) {
        var myPickItem = json['myPickId'][0];
        myPickId = myPickItem['id'];
        if (BaseModel.checkJsonKeys(myPickItem, ['pick_comment']) &&
            myPickItem['pick_comment'].isNotEmpty) {
          myPickCommentId = myPickItem['pick_comment'][0]['id'];
        }
      }
    }

    if (BaseModel.checkJsonKeys(json, ['full_screen_ad'])) {
      if (json['full_screen_ad'] == 'all' ||
          json['full_screen_ad'] == 'mobile') {
        fullScreenAd = true;
      }
    }

    if (BaseModel.checkJsonKeys(json, ['content'])) {
      content = json['content'];
    }

    List<Member> allPickedMember = [];
    allPickedMember.addAll(followingPickMembers);
    allPickedMember.addAll(otherPickMembers);
    if (Get.isRegistered<PickableItemController>(tag: 'News${json['id']}') ||
        Get.isPrepared<PickableItemController>(tag: 'News${json['id']}')) {
      final controller =
          Get.find<PickableItemController>(tag: 'News${json['id']}');
      if (controller.isLoading.isFalse) {
        controller.myPickId.value = myPickId;
        controller.myPickCommentId.value = myPickCommentId;
      }
      controller.pickCount.value = pickCount;
      controller.commentCount.value = commentCount;
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
          commentCount: commentCount,
          pickedMembers: allPickedMember,
          controllerTag: 'News${json['id']}',
        ),
        tag: 'News${json['id']}',
        fenix: true,
      );
    }

    return NewsListItem(
      id: json["id"],
      title: json["title"],
      url: json["url"],
      controllerTag: 'News${json['id']}',
      source: source,
      category: category,
      publishedDate: DateTime.parse(json["published_date"]).toLocal(),
      heroImageUrl: json["og_image"],
      payWall: payWall,
      fullScreenAd: fullScreenAd,
      pickCount: pickCount,
      commentCount: commentCount,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      showComment: showComment,
      myPickId: myPickId,
      fullContent: fullContent,
      latestPickTime: latestPickTime,
      content: content,
      myPickCommentId: myPickCommentId,
    );
  }
}
