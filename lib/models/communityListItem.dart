import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/story/storyPage.dart';

enum CommunityListItemType {
  pickStory,
  pickCollection,
  commentStory,
  commentCollection,
  createCollection,
  updateCollection,
}

class CommunityListItem {
  final CommunityListItemType type;
  final DateTime orderByTime;
  final RxString titleText;
  final String controllerTag;
  final RxnString heroImageUrl;
  final RxnString authorText;
  final VoidCallback tapItem;
  final VoidCallback tapAuthor;
  final Comment? showComment;
  final String itemId;
  final NewsListItem? newsListItem;
  final Collection? collection;
  final List<Member> itemBarMember;
  final String itemBarText;

  const CommunityListItem({
    required this.orderByTime,
    required this.type,
    required this.titleText,
    required this.controllerTag,
    required this.heroImageUrl,
    required this.authorText,
    required this.tapItem,
    required this.tapAuthor,
    required this.itemId,
    required this.showComment,
    required this.itemBarMember,
    required this.itemBarText,
    this.newsListItem,
    this.collection,
  });

  factory CommunityListItem.fromJson(Map<String, dynamic> json) {
    CommunityListItemType type = CommunityListItemType.pickStory;
    NewsListItem? newsListItem;
    Collection? collection;

    if (json.containsKey('story') && json['story'] != null) {
      newsListItem = NewsListItem.fromJson(json['story']);
    } else if (json.containsKey('collection') && json['collection'] != null) {
      collection = Collection.fromJson(json['collection']);
    } else {
      collection = Collection.fromJson(json);
    }

    if (json.containsKey('published_date') && json['published_date'] == null) {
      json['published_date'] = DateTime.now().toIso8601String();
    }

    DateTime orderByTime = DateTime.now().subtract(const Duration(days: 30));
    if (json.containsKey('picked_date')) {
      orderByTime = DateTime.parse(json['picked_date']);
      if (collection != null) {
        type = CommunityListItemType.pickCollection;
      }
    } else if (json.containsKey('published_date') &&
        json['published_date'] != null) {
      orderByTime = DateTime.parse(json['published_date']);
      if (newsListItem != null) {
        type = CommunityListItemType.commentStory;
      } else {
        type = CommunityListItemType.commentCollection;
      }
    } else {
      if (json['updatedAt'] != null) {
        type = CommunityListItemType.updateCollection;
      } else {
        type = CommunityListItemType.createCollection;
      }
      if (collection != null) {
        orderByTime = collection.updateTime;
      }
    }

    RxnString heroImageUrl = RxnString();
    RxnString authorText = RxnString();
    VoidCallback tapItem;
    VoidCallback tapAuthor;
    RxString titleText = RxString('');
    String controllerTag;
    Comment? showComment;
    String itemId;
    List<Member> itemBarMember = [];
    String itemBarText;

    switch (type) {
      case CommunityListItemType.pickStory:
      case CommunityListItemType.commentStory:
        heroImageUrl.value = newsListItem!.heroImageUrl ?? '';
        tapItem = () => Get.to(
              () => StoryPage(news: newsListItem!),
              fullscreenDialog: true,
            );

        authorText.value = newsListItem.source?.title;
        tapAuthor = () {
          if (newsListItem!.source != null) {
            Get.to(() => PublisherPage(
                  newsListItem!.source!,
                ));
          }
        };
        titleText.value = newsListItem.title;

        controllerTag = newsListItem.controllerTag;
        showComment = newsListItem.showComment;
        itemId = newsListItem.id;

        if (newsListItem.commentMembers != null &&
            newsListItem.commentMembers!.isNotEmpty) {
          itemBarMember.assignAll(newsListItem.commentMembers!);
          itemBarText = 'commentNews'.tr;
        } else {
          itemBarMember.assignAll(
              Get.find<PickableItemController>(tag: newsListItem.controllerTag)
                  .pickedMembers);
          itemBarText = 'pickNews'.tr;
        }
        break;
      case CommunityListItemType.pickCollection:
      case CommunityListItemType.commentCollection:
      case CommunityListItemType.createCollection:
      case CommunityListItemType.updateCollection:
        heroImageUrl =
            Get.find<PickableItemController>(tag: collection!.controllerTag)
                .collectionHeroImageUrl;
        tapItem = () => Get.to(
              () => CollectionPage(collection!),
            );

        if (Get.find<UserService>().isMember.isTrue &&
            Get.find<UserService>().currentUser.memberId ==
                collection.creator.memberId) {
          authorText.value = Get.find<UserService>().currentUser.customId;
        } else {
          authorText.value = collection.creator.customId;
        }

        tapAuthor = () =>
            Get.to(() => PersonalFilePage(viewMember: collection!.creator));
        titleText.value = collection.title;

        controllerTag = collection.controllerTag;
        showComment = collection.showComment;
        itemId = collection.id;
        if (type == CommunityListItemType.updateCollection) {
          itemBarMember.assign(collection.creator);
          itemBarText = 'updateCollection'.tr;
        } else if (type == CommunityListItemType.createCollection) {
          itemBarMember.assign(collection.creator);
          itemBarText = 'createANewCollection'.tr;
        } else if (collection.commentMembers != null &&
            collection.commentMembers!.isNotEmpty) {
          itemBarMember.assignAll(collection.commentMembers!);
          itemBarText = 'commentCollection'.tr;
        } else {
          itemBarMember.assignAll(collection.followingPickMembers!);
          itemBarText = 'pickCollection'.tr;
        }
        break;
    }

    return CommunityListItem(
      orderByTime: orderByTime,
      newsListItem: newsListItem,
      collection: collection,
      type: type,
      authorText: authorText,
      controllerTag: controllerTag,
      titleText: titleText,
      heroImageUrl: heroImageUrl,
      tapAuthor: tapAuthor,
      tapItem: tapItem,
      showComment: showComment,
      itemId: itemId,
      itemBarMember: itemBarMember,
      itemBarText: itemBarText,
    );
  }
}
