import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/pickService.dart';

class Collection {
  final String id;
  String title;
  final String slug;
  final Member creator;
  CollectionFormat format;
  CollectionPublic public;
  List<CollectionStory>? collectionPicks;
  final String controllerTag;
  String ogImageUrl;
  final DateTime publishedTime;
  final int commentCount;
  final int pickCount;
  final List<Member>? pickedMemberList;
  CollectionStatus status;

  Collection({
    required this.id,
    required this.title,
    required this.slug,
    required this.creator,
    required this.controllerTag,
    required this.ogImageUrl,
    required this.publishedTime,
    this.format = CollectionFormat.folder,
    this.public = CollectionPublic.public,
    this.collectionPicks,
    this.commentCount = 0,
    this.pickCount = 0,
    this.pickedMemberList,
    this.status = CollectionStatus.publish,
  });

  factory Collection.fromFetchCollectionList(
      Map<String, dynamic> json, Member viewMember) {
    String imageUrl;
    if (json['heroImage']['file'] != null) {
      imageUrl = json['heroImage']['file']['url'];
    } else {
      imageUrl = json['heroImage']['urlOriginal'];
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

    if (Get.isRegistered<PickableItemController>(
            tag: 'Collection${json['id']}') ||
        Get.isPrepared<PickableItemController>(
            tag: 'Collection${json['id']}')) {
      final controller =
          Get.find<PickableItemController>(tag: 'Collection${json['id']}');
      // if (controller.isLoading.isFalse) {
      //   controller.myPickId.value = myPickId;
      //   controller.myPickCommentId.value = myPickCommentId;
      // }
      // controller.pickCount.value = pickCount;
      controller.commentCount.value = json['commentCount'];
      // controller.pickedMembers.assignAll(allPickedMember);
    } else {
      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: json["id"],
          pickRepos: PickService(),
          objective: PickObjective.collection,
          // myPickId: myPickId,
          // myPickCommentId: myPickCommentId,
          // pickCount: pickCount,
          commentCount: json['commentCount'],
          // pickedMembers: allPickedMember,
          controllerTag: 'Collection${json['id']}',
        ),
        tag: 'Collection${json['id']}',
        fenix: true,
      );
    }

    return Collection(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      creator: viewMember,
      commentCount: json['commentCount'],
      publishedTime: DateTime.parse(json['createdAt']),
      ogImageUrl: imageUrl,
      controllerTag: 'Collection${json['id']}',
      format: format,
    );
  }
}
