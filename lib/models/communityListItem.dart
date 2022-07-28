import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:shimmer/shimmer.dart';

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
  final Widget titleWidget;
  final String controllerTag;
  final Widget heroImageWidget;
  final Widget authorTextWidget;
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
    required this.orderByTime,
    required this.type,
    required this.titleWidget,
    required this.controllerTag,
    required this.heroImageWidget,
    required this.authorTextWidget,
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
    } else {
      collection = Collection.fromJson(json);
    }

    DateTime orderByTime = DateTime.now().subtract(const Duration(days: 30));
    if (json.containsKey('picked_date')) {
      orderByTime = DateTime.parse(json['picked_date']);
      if (collection != null) {
        type = CommunityListItemType.pickCollection;
      }
    } else if (json.containsKey('published_date')) {
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
      orderByTime = collection!.updateTime;
    }

    Widget heroImageWidget;
    Widget authorTextWidget;
    VoidCallback tapItem;
    VoidCallback tapAuthor;
    Widget titleWidget;
    Widget infoWidget;
    String controllerTag;
    Comment? showComment;
    String itemId;
    List<Member> itemBarMember = [];
    String itemBarText;

    switch (type) {
      case CommunityListItemType.pickStory:
      case CommunityListItemType.commentStory:
        heroImageWidget = CachedNetworkImage(
          imageUrl: newsListItem!.heroImageUrl ?? '',
          placeholder: (context, url) => SizedBox(
            width: Get.width,
            height: Get.width / 2,
            child: Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Container(
                width: Get.width,
                height: Get.width / 2,
                color: Colors.white,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(),
          imageBuilder: (context, imageProvider) {
            return Image(
              image: imageProvider,
              width: Get.width,
              height: Get.width / 2,
              fit: BoxFit.cover,
            );
          },
        );
        tapItem = () => Get.to(
              () => StoryPage(news: newsListItem!),
              fullscreenDialog: true,
            );

        authorTextWidget = newsListItem.source != null
            ? ExtendedText(
                newsListItem.source!.title,
                joinZeroWidthSpace: true,
                style: const TextStyle(color: readrBlack50, fontSize: 14),
              )
            : Container();
        tapAuthor = () {
          if (newsListItem!.source != null) {
            Get.to(() => PublisherPage(
                  newsListItem!.source!,
                ));
          }
        };
        titleWidget = ExtendedText(
          newsListItem.title,
          joinZeroWidthSpace: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: readrBlack87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        );
        infoWidget = NewsInfo(newsListItem);
        controllerTag = newsListItem.controllerTag;
        showComment = newsListItem.showComment;
        itemId = newsListItem.id;

        if (newsListItem.commentMembers != null &&
            newsListItem.commentMembers!.isNotEmpty) {
          itemBarMember.assignAll(newsListItem.commentMembers!);
          itemBarText = '在這篇留言';
        } else {
          itemBarMember.assignAll(
              Get.find<PickableItemController>(tag: newsListItem.controllerTag)
                  .pickedMembers);
          itemBarText = '精選了這篇';
        }
        break;
      case CommunityListItemType.pickCollection:
      case CommunityListItemType.commentCollection:
      case CommunityListItemType.createCollection:
      case CommunityListItemType.updateCollection:
        heroImageWidget = Obx(
          () => CachedNetworkImage(
            imageUrl:
                Get.find<PickableItemController>(tag: collection!.controllerTag)
                    .collectionHeroImageUrl
                    .value!,
            placeholder: (context, url) => SizedBox(
              width: Get.width,
              height: Get.width / 2,
              child: Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  width: Get.width,
                  height: Get.width / 2,
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(),
            imageBuilder: (context, imageProvider) {
              return Image(
                image: imageProvider,
                width: Get.width,
                height: Get.width / 2,
                fit: BoxFit.cover,
              );
            },
          ),
        );
        tapItem = () => Get.to(
              () => CollectionPage(collection!),
            );
        authorTextWidget = Obx(
          () {
            String author = collection!.creator.customId;
            if (Get.find<UserService>().isMember.isTrue &&
                Get.find<UserService>().currentUser.memberId ==
                    collection.creator.memberId) {
              author = Get.find<UserService>().currentUser.customId;
            }

            return ExtendedText(
              '@$author',
              joinZeroWidthSpace: true,
              style: const TextStyle(color: readrBlack50, fontSize: 14),
            );
          },
        );
        tapAuthor = () =>
            Get.to(() => PersonalFilePage(viewMember: collection!.creator));
        titleWidget = Obx(
          () => ExtendedText(
            Get.find<PickableItemController>(tag: collection!.controllerTag)
                    .collectionTitle
                    .value ??
                collection.title,
            joinZeroWidthSpace: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: readrBlack87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        infoWidget = CollectionInfo(collection!, key: Key(collection.id));
        controllerTag = collection.controllerTag;
        showComment = collection.showComment;
        itemId = collection.id;
        if (type == CommunityListItemType.updateCollection) {
          itemBarMember.assign(collection.creator);
          itemBarText = '更新了一個集錦';
        } else if (type == CommunityListItemType.createCollection) {
          itemBarMember.assign(collection.creator);
          itemBarText = '建立了一個新的集錦';
        } else if (collection.commentMembers != null &&
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
      orderByTime: orderByTime,
      newsListItem: newsListItem,
      collection: collection,
      type: type,
      authorTextWidget: authorTextWidget,
      controllerTag: controllerTag,
      titleWidget: titleWidget,
      heroImageWidget: heroImageWidget,
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
