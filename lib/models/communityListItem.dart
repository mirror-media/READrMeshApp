import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/communityListItemType.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';

class CommunityListItem {
  final CommunityListItemType type;
  final DateTime orderByTime;
  final String? titleText;
  final String controllerTag;
  final String? heroImageUrl;
  final String? authorText;
  final Comment? showComment;
  final String? itemId;
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
    required this.itemId,
    required this.itemBarMember,
    this.showComment,
    this.itemBarText,
    this.newsListItem,
    this.collection,
  });

  String? get displayAuthorText {
    final userService = Get.find<UserService>();
    final isMember = userService.isMember;

    if (type == CommunityListItemType.commentStory ||
        type == CommunityListItemType.pickStory) {
      return authorText;
    } else if (isMember.isTrue &&
        userService.currentUser.memberId == collection?.creator.memberId) {
      return '@${userService.currentUser.customId}';
    } else if (authorText != null) {
      return '@$authorText';
    }

    return null;
  }

  String? get displayTitleText {
    if (type != CommunityListItemType.commentStory &&
        type != CommunityListItemType.pickStory) {
      try {
        final pickableController =
            Get.find<PickableItemController>(tag: collection!.controllerTag);
        final collectionTitleValue = pickableController.collectionTitle.value;
        if (collectionTitleValue != null) {
          return collectionTitleValue;
        }
      } catch (e) {
        // 如果找不到 controller，則使用默認標題
      }
    }

    return titleText;
  }

  bool get shouldShowCollectionTag =>
      type != CommunityListItemType.commentStory &&
      type != CommunityListItemType.pickStory;

  PickObjective get commentObjective {
    switch (type) {
      case CommunityListItemType.commentStory:
      case CommunityListItemType.pickStory:
        return PickObjective.story;
      case CommunityListItemType.pickCollection:
      case CommunityListItemType.commentCollection:
      case CommunityListItemType.createCollection:
      case CommunityListItemType.updateCollection:
        return PickObjective.collection;
      default:
        throw Exception('未知的項目類型');
    }
  }

  List<Member> get firstTwoMembers {
    List<Member> firstTwoMember = [];
    for (int i = 0; i < itemBarMember.length; i++) {
      if (!firstTwoMember
          .any((element) => element.memberId == itemBarMember[i].memberId)) {
        firstTwoMember.add(itemBarMember[i]);
      }
      if (firstTwoMember.length == 2) {
        break;
      }
    }
    return firstTwoMember;
  }

  factory CommunityListItem.fromJson(Map<String, dynamic> json) {
    try {
      final newsListItem = NewsListItem.fromJson(json);

      List<Member> itemBarMembers = [];
      Comment? showComment;
      String? itemBarText;

      if (json['following_actions'] != null) {
        for (var action in json['following_actions'] as List) {
          itemBarMembers.add(Member.fromJson(action['member']));

          if (action['kind'] == 'comment' && action['content'] != null) {
            showComment = Comment(
              id: 'temp-${action['createdAt']}-${Member.fromJson(action['member']).memberId}',
              content: action['content'],
              member: Member.fromJson(action['member']),
              publishDate: DateTime.parse(action['createdAt']),
              state: 'active',
            );
          }

          switch (action['kind']) {
            case 'pick':
              itemBarText = 'pickNews';
              break;
            case 'comment':
              if (itemBarText == null || itemBarText == 'readNews') {
                itemBarText = 'commentNews';
              }
              break;
            case 'read':
              itemBarText ??= 'readNews';
              break;
          }
        }
      }

      return CommunityListItem(
        orderByTime: DateTime.parse(json['published_date']),
        type: CommunityListItemType.pickStory,
        newsListItem: newsListItem,
        titleText: json['og_title'],
        controllerTag: 'News${json['id']}',
        heroImageUrl: json['og_image'],
        authorText: json['publisher']?['title'],
        showComment: showComment,
        itemId: json['id']?.toString(),
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
