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
    try {
      print('1. Start mapping CommunityListItem');
      print('2. Processing story/collection type');

      final newsListItem = NewsListItem.fromJson({
        'id': json['id']?.toString() ?? '',
        'url': json['url'] ?? '',
        'title': json['og_title'] ?? '',
        'og_image': json['og_image'] ?? '',
        'source': json['publisher'],
        'published_date': json['published_date'],
      });

      print('3. Successfully created NewsListItem');

      return CommunityListItem(
        orderByTime: DateTime.parse(json['published_date']),
        type: CommunityListItemType.pickStory,
        newsListItem: newsListItem,
        titleText: RxString(json['og_title'] ?? ''),
        controllerTag: 'News${json['id']}',
        heroImageUrl: RxnString(json['og_image']),
        authorText: RxnString(json['publisher']?['title']),
        tapItem: () => {},
        tapAuthor: () => {},
        showComment: null,
        itemId: json['id']?.toString() ?? '',
        itemBarMember: [],
        itemBarText: '',
      );
    } catch (e, stackTrace) {
      print('Error in CommunityListItem.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
