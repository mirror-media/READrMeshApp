import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';

class NewsListItem {
  final String id;
  final String title;
  final String url;
  final String? summary;
  final String? content;
  final Publisher? source;
  final Category? category;
  final DateTime publishedDate;
  final String? heroImageUrl;
  final bool payWall;
  final bool fullScreenAd;
  final bool fullContent;
  final Comment? showComment;
  final List<Member>? commentMembers;
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
    this.fullContent = false,
    this.showComment,
    this.commentMembers,
    required this.controllerTag,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json,
      {bool updateController = true}) {
    Publisher? source;
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
    String? content;
    List<Member>? commentMembers;

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

    if (BaseModel.checkJsonKeys(json, ['comment']) &&
        json['comment'].isNotEmpty) {
      commentMembers = [];
      for (var commentItem in json['comment']) {
        commentMembers.add(Comment.fromJson(commentItem).member);
      }
      showComment = Comment.fromJson(json['comment'][0]);
    }

    if (BaseModel.checkJsonKeys(json, ['allComments']) &&
        json['allComments'].isNotEmpty) {
      for (var comment in json['allComments']) {
        allComments.add(Comment.fromJson(comment));
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

    /// update value if controller exists
    /// otherwise create one
    if (updateController) {
      if (Get.isRegistered<PickableItemController>(tag: 'News${json['id']}') ||
          Get.isPrepared<PickableItemController>(tag: 'News${json['id']}')) {
        final controller =
            Get.find<PickableItemController>(tag: 'News${json['id']}');
        controller.pickCount.value = pickCount;
        controller.commentCount.value = commentCount;
        controller.pickedMembers.assignAll(allPickedMember);
      } else {
        Get.lazyPut<PickableItemController>(
          () => PickableItemController(
            targetId: json["id"],
            objective: PickObjective.story,
            pickCount: pickCount,
            commentCount: commentCount,
            pickedMembers: allPickedMember,
            controllerTag: 'News${json['id']}',
          ),
          tag: 'News${json['id']}',
          fenix: true,
        );
      }
    }

    DateTime publishDate = DateTime.now();
    if (BaseModel.checkJsonKeys(json, ['createdAt'])) {
      publishDate = DateTime.parse(json["createdAt"]).toLocal();
    } else {
      publishDate = DateTime.parse(json["published_date"]).toLocal();
    }

    return NewsListItem(
      id: json["id"],
      title: json["title"],
      url: json["url"],
      controllerTag: 'News${json['id']}',
      source: source,
      category: category,
      publishedDate: publishDate,
      heroImageUrl: json["og_image"],
      payWall: payWall,
      fullScreenAd: fullScreenAd,
      showComment: showComment,
      fullContent: fullContent,
      content: content,
      commentMembers: commentMembers,
    );
  }
}
