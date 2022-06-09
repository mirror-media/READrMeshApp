import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/story/storyPage.dart';

enum CommunityListItemType {
  pickStory,
  pickCollection,
  commentStory,
  commentCollection,
}

class CommunityListItem {
  final CommunityListItemType type;
  final DateTime pickOrCommentTime;
  final String title;
  final String controllerTag;
  final String heroImageUrl;
  final String authorText;
  final VoidCallback tapItem;
  final VoidCallback tapAuthor;
  final Widget infoWidget;
  final Comment? showComment;
  final String itemId;
  final NewsListItem? newsListItem;
  final Collection? collection;
  final List<Member> itemBarMember;
  final String itemBarText;

  const CommunityListItem({
    required this.pickOrCommentTime,
    required this.type,
    required this.title,
    required this.controllerTag,
    required this.heroImageUrl,
    required this.authorText,
    required this.tapItem,
    required this.tapAuthor,
    required this.infoWidget,
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
    }

    DateTime pickOrCommentTime =
        DateTime.now().subtract(const Duration(days: 30));
    if (json.containsKey('picked_date')) {
      pickOrCommentTime = DateTime.parse(json['picked_date']);
      if (collection != null) {
        type = CommunityListItemType.pickCollection;
      }
    } else if (json.containsKey('published_date')) {
      pickOrCommentTime = DateTime.parse(json['published_date']);
      if (newsListItem != null) {
        type = CommunityListItemType.commentStory;
      } else {
        type = CommunityListItemType.commentCollection;
      }
    }

    String heroImageUrl;
    String authorText;
    VoidCallback tapItem;
    VoidCallback tapAuthor;
    String title;
    Widget infoWidget;
    String controllerTag;
    Comment? showComment;
    String itemId;
    List<Member> itemBarMember = [];
    String itemBarText;

    switch (type) {
      case CommunityListItemType.pickStory:
      case CommunityListItemType.commentStory:
        heroImageUrl = newsListItem!.heroImageUrl ?? '';
        tapItem = () => Get.to(
              () => StoryPage(news: newsListItem!),
              fullscreenDialog: true,
            );
        authorText = newsListItem.source.title;
        tapAuthor = () => Get.to(() => PublisherPage(
              newsListItem!.source,
            ));
        title = newsListItem.title;
        infoWidget = NewsInfo(newsListItem);
        controllerTag = newsListItem.controllerTag;
        showComment = newsListItem.showComment;
        itemId = newsListItem.id;

        if (newsListItem.commentMembers != null &&
            newsListItem.commentMembers!.isNotEmpty) {
          itemBarMember.assignAll(newsListItem.commentMembers!);
          itemBarText = '在這篇留言';
        } else {
          itemBarMember.assignAll(newsListItem.followingPickMembers);
          itemBarText = '精選了這篇';
        }
        break;
      case CommunityListItemType.pickCollection:
      case CommunityListItemType.commentCollection:
        heroImageUrl = collection!.ogImageUrl;
        tapItem = () => Get.to(
              () => CollectionPage(collection!),
            );
        authorText = '@${collection.creator.customId}';
        tapAuthor = () =>
            Get.to(() => PersonalFilePage(viewMember: collection!.creator));
        title = collection.title;
        infoWidget = CollectionInfo(collection, key: Key(collection.id));
        controllerTag = collection.controllerTag;
        showComment = collection.showComment;
        itemId = collection.id;
        if (collection.commentMembers != null &&
            collection.commentMembers!.isNotEmpty) {
          itemBarMember.assignAll(collection.commentMembers!);
          itemBarText = '在這個集錦留言';
        } else {
          itemBarMember.assignAll(collection.followingPickMembers!);
          itemBarText = '精選了這個集錦';
        }
        break;
    }

    return CommunityListItem(
      pickOrCommentTime: pickOrCommentTime,
      newsListItem: newsListItem,
      collection: collection,
      type: type,
      authorText: authorText,
      controllerTag: controllerTag,
      title: title,
      heroImageUrl: heroImageUrl,
      tapAuthor: tapAuthor,
      tapItem: tapItem,
      infoWidget: infoWidget,
      showComment: showComment,
      itemId: itemId,
      itemBarMember: itemBarMember,
      itemBarText: itemBarText,
    );
  }
}
