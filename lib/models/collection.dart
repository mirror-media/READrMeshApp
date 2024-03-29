import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';

class Collection {
  final String id;
  String title;
  final String slug;
  final Member creator;
  CollectionFormat format;
  CollectionPublic public;
  List<CollectionPick>? collectionPicks;
  final String controllerTag;
  String ogImageUrl;
  String ogImageId;
  final DateTime updateTime;
  final int commentCount;
  final int pickCount;
  final List<Member>? followingPickMembers;
  final List<Member>? otherPickMembers;
  final List<Member>? commentMembers;
  CollectionStatus status;
  final Comment? showComment;

  Collection({
    required this.id,
    required this.title,
    required this.slug,
    required this.creator,
    required this.controllerTag,
    required this.ogImageUrl,
    required this.updateTime,
    required this.ogImageId,
    this.format = CollectionFormat.folder,
    this.public = CollectionPublic.public,
    this.collectionPicks,
    this.commentCount = 0,
    this.pickCount = 0,
    this.status = CollectionStatus.publish,
    this.showComment,
    this.followingPickMembers,
    this.otherPickMembers,
    this.commentMembers,
  });

  factory Collection.fromJsonWithMember(
      Map<String, dynamic> json, Member viewMember) {
    String imageUrl = '';
    if (json['heroImage'] != null) {
      imageUrl = json['heroImage']['resized']['original'];
    }

    CollectionFormat format;
    switch (json['format']) {
      case 'timeline':
        format = CollectionFormat.timeline;
        break;
      default:
        format = CollectionFormat.folder;
        break;
    }

    int pickCount = json['picksCount'] ?? 0;

    List<Member> allPickedMember = [];
    if (BaseModel.checkJsonKeys(json, ['followingPicks']) &&
        json['followingPicks'].isNotEmpty) {
      for (var pick in json['followingPicks']) {
        allPickedMember.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherPicks']) &&
        json['otherPicks'].isNotEmpty) {
      for (var pick in json['otherPicks']) {
        allPickedMember.add(Member.fromJson(pick['member']));
      }
    }

    DateTime updateTime;
    if (json['updatedAt'] != null) {
      updateTime = DateTime.parse(json['updatedAt']);
    } else {
      updateTime = DateTime.parse(json['createdAt']);
    }

    /// update value if controller exists
    /// otherwise create one
    if (Get.isRegistered<PickableItemController>(
            tag: 'Collection${json['id']}') ||
        Get.isPrepared<PickableItemController>(
            tag: 'Collection${json['id']}')) {
      final controller =
          Get.find<PickableItemController>(tag: 'Collection${json['id']}');
      controller.pickCount.value = pickCount;
      controller.commentCount.value = json['commentCount'] ?? 0;
      controller.pickedMembers.assignAll(allPickedMember);
      controller.collectionTitle.value = json['title'];
      controller.collectionHeroImageUrl.value = imageUrl;
      controller.collectionUpdatetime.value = updateTime;
    } else {
      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: json["id"],
          objective: PickObjective.collection,
          pickCount: pickCount,
          commentCount: json['commentCount'] ?? 0,
          pickedMembers: allPickedMember,
          controllerTag: 'Collection${json['id']}',
          collectionHeroImageUrl: imageUrl,
          collectionTitle: json['title'],
          collectionUpdatetime: updateTime,
        ),
        tag: 'Collection${json['id']}',
        fenix: true,
      );
    }

    CollectionStatus status = CollectionStatus.publish;
    if (BaseModel.checkJsonKeys(json, ['status'])) {
      switch (json['status'] as String) {
        case 'delete':
          status = CollectionStatus.delete;
          break;
        case 'draft':
          status = CollectionStatus.draft;
          break;
        default:
          status = CollectionStatus.publish;
      }
    }

    return Collection(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      creator: viewMember,
      commentCount: json['commentCount'] ?? 0,
      updateTime: updateTime,
      ogImageUrl: imageUrl,
      controllerTag: 'Collection${json['id']}',
      format: format,
      ogImageId: json['heroImage']['id'],
      status: status,
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['heroImage'] != null) {
      imageUrl = json['heroImage']['resized']['original'];
    }

    CollectionFormat format;
    switch (json['format']) {
      case 'timeline':
        format = CollectionFormat.timeline;
        break;
      default:
        format = CollectionFormat.folder;
        break;
    }

    int pickCount = 0;
    if (BaseModel.checkJsonKeys(json, ['picksCount'])) {
      pickCount = json['picksCount'];
    }

    Comment? showComment;
    List<Member>? commentMembers;
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

    List<Member> allPickedMember = [];
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    if (BaseModel.checkJsonKeys(json, ['followingPicks']) &&
        json['followingPicks'].isNotEmpty) {
      for (var pick in json['followingPicks']) {
        followingPickMembers.add(Member.fromJson(pick['member']));
      }
      allPickedMember.assignAll(followingPickMembers);
    }

    if (BaseModel.checkJsonKeys(json, ['otherPicks']) &&
        json['otherPicks'].isNotEmpty) {
      for (var pick in json['otherPicks']) {
        otherPickMembers.add(Member.fromJson(pick['member']));
      }
      allPickedMember.addAll(otherPickMembers);
    }

    CollectionStatus status = CollectionStatus.publish;
    if (BaseModel.checkJsonKeys(json, ['status'])) {
      switch (json['status'] as String) {
        case 'delete':
          status = CollectionStatus.delete;
          break;
        case 'draft':
          status = CollectionStatus.draft;
          break;
        default:
          status = CollectionStatus.publish;
      }
    }

    DateTime updateTime;
    if (json['updatedAt'] != null) {
      updateTime = DateTime.parse(json['updatedAt']);
    } else {
      updateTime = DateTime.parse(json['createdAt']);
    }

    /// update value if controller exists
    /// otherwise create one
    if (Get.isRegistered<PickableItemController>(
            tag: 'Collection${json['id']}') ||
        Get.isPrepared<PickableItemController>(
            tag: 'Collection${json['id']}')) {
      final controller =
          Get.find<PickableItemController>(tag: 'Collection${json['id']}');
      controller.pickCount.value = pickCount;
      controller.collectionTitle.value = json['title'];
      controller.collectionHeroImageUrl.value = imageUrl;
      controller.pickedMembers.assignAll(allPickedMember);
      if (BaseModel.checkJsonKeys(json, ['commentCount'])) {
        controller.commentCount.value = json['commentCount'];
      }
      controller.collectionUpdatetime.value = updateTime;
    } else {
      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: json["id"],
          objective: PickObjective.collection,
          pickCount: pickCount,
          controllerTag: 'Collection${json['id']}',
          collectionHeroImageUrl: imageUrl,
          collectionTitle: json['title'],
          pickedMembers: allPickedMember,
          commentCount: json['commentCount'] ?? 0,
          collectionUpdatetime: updateTime,
        ),
        tag: 'Collection${json['id']}',
        fenix: true,
      );
    }

    return Collection(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      creator: Member.fromJson(json['creator']),
      ogImageUrl: imageUrl,
      updateTime: updateTime,
      format: format,
      ogImageId: json['heroImage']['id'],
      controllerTag: 'Collection${json['id']}',
      showComment: showComment,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      commentMembers: commentMembers,
      status: status,
    );
  }
}
