import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
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
  final String? itemBarText;

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
    try {
      final newsListItem = NewsListItem.fromJson({
        'id': json['id']?.toString(),
        'url': json['url'],
        'title': json['og_title'],
        'og_image': json['og_image'],
        'source': json['publisher'],
        'published_date': json['published_date'],
        'readCount': json['readCount'],
        'commentCount': json['commentCount'],
      });

      List<Member> itemBarMembers = [];
      Comment? showComment;
      String? itemBarText;

      if (json['following_actions'] != null) {
        for (var action in json['following_actions'] as List) {
          itemBarMembers.add(Member.fromJson(action['member']));

          if (action['kind'] == 'comment' && action['content'] != null) {
            showComment = Comment(
              id: '',
              content: action['content'],
              member: Member.fromJson(action['member']),
              publishDate: DateTime.parse(action['createdAt']),
              state: 'active',
            );
          }

          switch (action['kind']) {
            case 'pick':
              itemBarText = 'pickNews'.tr;
              break;
            case 'comment':
              if (itemBarText == null || itemBarText == 'readNews'.tr) {
                itemBarText = 'commentNews'.tr;
              }
              break;
            case 'read':
              itemBarText ??= 'readNews'.tr;
              break;
          }
        }
      }

      return CommunityListItem(
        orderByTime: DateTime.parse(json['published_date']),
        type: CommunityListItemType.pickStory,
        newsListItem: newsListItem,
        titleText: RxString(json['og_title'] ?? ''),
        controllerTag: 'News${json['id']}',
        heroImageUrl: RxnString(json['og_image']),
        authorText: RxnString(json['publisher']?['title']),
        tapItem: () => Get.to(() => StoryPage(news: newsListItem)),
        tapAuthor: () => Get.to(() => PublisherPage(json['publisher'])),
        showComment: showComment,
        itemId: json['id']?.toString() ?? '',
        itemBarMember: itemBarMembers,
        itemBarText: itemBarText,
      );
    } catch (e, stackTrace) {
      print('Error in CommunityListItem.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
