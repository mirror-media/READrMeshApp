import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/community/comment/commentBottomSheet.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/mainAppBar.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:readr/pages/community/community_controller.dart';

class CommunityPage extends GetView<CommunityController> {
  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized.value) {
      controller.initPage();
    }
    return Scaffold(
      body: GetBuilder<CommunityController>(
        builder: (controller) {
          if (controller.isError.value) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                MainAppBar(),
                SliverFillRemaining(
                  child: ErrorPage(
                    error: controller.error.value,
                    onPressed: () => controller.initPage(),
                    hideAppbar: true,
                  ),
                ),
              ],
            );
          }

          if (controller.isInitialized.value) {
            return ScrollsToTop(
              onScrollsToTop: (event) async => controller.scrollToTopAndRefresh(),
              child: _buildBody(context),
            );
          }

          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              MainAppBar(),
              SliverFillRemaining(
                child: HomeSkeletonScreen(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await controller.updateCommunityPage(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller.scrollController,
        slivers: [
          MainAppBar(),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.communityList.isEmpty) {
                  return _emptyWidget(context);
                }

                int end = 3;
                if (controller.communityList.length < 3) {
                  end = controller.communityList.length;
                }

                return _buildList(
                  context,
                  controller.communityList.sublist(0, end),
                  {2: 'social_AT1'},
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (Get.find<RecommendMemberBlockController>().recommendMembers.isEmpty ||
                    controller.communityList.isEmpty) {
                  return Container();
                }

                return Container(
                  color: Theme.of(context).backgroundColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RecommendFollowBlock(Get.find<RecommendMemberBlockController>()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.communityList.length < 3) {
                  return Container();
                }

                return _buildList(
                  context,
                  controller.communityList.sublist(3),
                  {
                    4: 'social_AT2',
                    10: 'social_AT3',
                    14: 'social_AT4',
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _bottomWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget(BuildContext context) {
    final recommendMemberBlockController = Get.find<RecommendMemberBlockController>();
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(87.5, 22, 87.5, 26),
            child: SvgPicture.asset(
              Theme.of(context).brightness == Brightness.light ? noFollowingSvg : noFollowingDarkSvg,
            ),
          ),
          Text(
            'communityEmptyTitle'.tr,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              text: 'communityEmptyDescription'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              children: const [
                TextSpan(
                  text: ' 👀',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 32,
          ),
          RecommendFollowBlock(
            recommendMemberBlockController,
            showTitleBar: false,
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<CommunityListItem> communityList,
    Map<int, String> adIndexAndId,
  ) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (adIndexAndId.containsKey(index)) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildItem(context, communityList[index]),
              NativeAdWidget(
                key: Key(adIndexAndId[index]!),
                adHeight: context.width * 0.82,
                topWidget: const SizedBox(height: 8),
                adBgColor: Theme.of(context).backgroundColor,
                factoryId: 'full',
                adUnitIdKey: adIndexAndId[index]!,
              ),
            ],
          );
        }

        return _buildItem(context, communityList[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: communityList.length,
    );
  }

  Widget _buildItem(BuildContext context, CommunityListItem item) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _itemBar(context, item),
          InkWell(
            onTap: item.tapItem,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Obx(
                      () => CachedNetworkImage(
                        imageUrl: item.heroImageUrl.value ?? '',
                        placeholder: (context, url) => SizedBox(
                          width: Get.width,
                          height: Get.width / 2,
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).dividerColor,
                            highlightColor: Theme.of(context).shadowColor,
                            child: Container(
                              width: Get.width,
                              height: Get.width / 2,
                              color: Theme.of(context).backgroundColor,
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
                    ),
                    if (item.type != CommunityListItemType.commentStory && item.type != CommunityListItemType.pickStory)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: CollectionTag(),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: GestureDetector(
                    onTap: item.tapAuthor,
                    child: Obx(
                      () {
                        String author = '';
                        if (item.type == CommunityListItemType.commentStory ||
                            item.type == CommunityListItemType.pickStory) {
                          author = item.authorText.value ?? '';
                        } else if (Get.find<UserService>().isMember.isTrue &&
                            Get.find<UserService>().currentUser.memberId == item.collection!.creator.memberId) {
                          author = '@${Get.find<UserService>().currentUser.customId}';
                        } else {
                          author = '@${item.authorText.value ?? ''}';
                        }

                        return ExtendedText(
                          author,
                          joinZeroWidthSpace: true,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 20, right: 20, bottom: 8),
                  child: Obx(
                    () {
                      String title = item.titleText.value;
                      if (item.type != CommunityListItemType.commentStory &&
                          item.type != CommunityListItemType.pickStory) {
                        title = Get.find<PickableItemController>(tag: item.collection!.controllerTag)
                                .collectionTitle
                                .value ??
                            item.titleText.value;
                      }
                      return ExtendedText(
                        title,
                        joinZeroWidthSpace: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child:
                      (item.type == CommunityListItemType.commentStory || item.type == CommunityListItemType.pickStory)
                          ? NewsInfo(
                              item.newsListItem!,
                              key: Key(item.newsListItem!.id),
                            )
                          : CollectionInfo(
                              item.collection!,
                              key: Key(item.collection!.id),
                            ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PickBar(
              item.controllerTag,
              showPickTooltip: item.itemId == controller.communityList.first.itemId,
            ),
          ),
          if (item.showComment != null) ...[
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            InkWell(
              onTap: () async {
                PickObjective objective;
                switch (item.type) {
                  case CommunityListItemType.commentStory:
                  case CommunityListItemType.pickStory:
                    objective = PickObjective.story;
                    break;
                  case CommunityListItemType.pickCollection:
                  case CommunityListItemType.commentCollection:
                  case CommunityListItemType.createCollection:
                  case CommunityListItemType.updateCollection:
                    objective = PickObjective.collection;
                    break;
                }
                await CommentBottomSheet.showCommentBottomSheet(
                  context: context,
                  clickComment: item.showComment!,
                  objective: objective,
                  id: item.itemId,
                  controllerTag: item.controllerTag,
                );
              },
              child: _commentsWidget(context, item.showComment!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemBar(BuildContext context, CommunityListItem item) {
    if (item.itemBarMember.isEmpty) {
      return Container();
    }
    List<Member> firstTwoMember = [];
    for (int i = 0; i < item.itemBarMember.length; i++) {
      firstTwoMember.addIf(
          !firstTwoMember.any((element) => element.memberId == item.itemBarMember[i].memberId), item.itemBarMember[i]);
      if (firstTwoMember.length == 2) {
        break;
      }
    }

    List<Widget> children = [
      ProfilePhotoStack(
        firstTwoMember,
        14,
        key: ObjectKey(firstTwoMember),
      ),
      const SizedBox(width: 8),
    ];

    if (firstTwoMember.length == 1) {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
            joinZeroWidthSpace: true,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(Text(
        item.itemBarText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    } else {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
            joinZeroWidthSpace: true,
            style: Theme.of(context).textTheme.titleSmall,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(Text(
        'and'.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
      ));
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[1]));
          },
          child: ExtendedText(
            firstTwoMember[1].nickname,
            joinZeroWidthSpace: true,
            style: Theme.of(context).textTheme.titleSmall,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(Text(
        '${'both'.tr}${item.itemBarText}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
      ));
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              children: children,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              PickObjective objective;
              String? url;

              if (item.type == CommunityListItemType.pickStory || item.type == CommunityListItemType.commentStory) {
                objective = PickObjective.story;
                url = item.newsListItem!.url;
              } else {
                objective = PickObjective.collection;
                url = await DynamicLinkHelper.createCollectionLink(item.collection!);
              }
              await showMoreActionSheet(
                context: context,
                objective: objective,
                id: item.itemId,
                controllerTag: item.controllerTag,
                url: url,
                heroImageUrl: item.newsListItem?.heroImageUrl,
                newsListItem: item.newsListItem,
              );
            },
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            constraints: const BoxConstraints(maxHeight: 18),
            icon: Icon(
              PlatformIcons(context).ellipsis,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentsWidget(BuildContext context, Comment comment) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      color: Theme.of(context).backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => PersonalFilePage(viewMember: comment.member));
            },
            child: ProfilePhotoWidget(
              comment.member,
              22,
              textSize: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => PersonalFilePage(
                                viewMember: comment.member,
                              ));
                        },
                        child: ExtendedText(
                          comment.member.nickname,
                          maxLines: 1,
                          joinZeroWidthSpace: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14),
                          strutStyle: const StrutStyle(
                            forceStrutHeight: true,
                            leading: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    comment.publishDate != null
                        ? Timestamp(
                            comment.publishDate!,
                            key: ObjectKey(comment),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8.5, bottom: 20),
                  width: double.maxFinite,
                  child: ExtendedText(
                    comment.content,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.displaySmall,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      leading: 0.5,
                    ),
                    joinZeroWidthSpace: true,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.end,
                      child: RichText(
                        strutStyle: const StrutStyle(
                          forceStrutHeight: true,
                          leading: 0.5,
                        ),
                        text: TextSpan(
                          text: '... ',
                          style: Theme.of(context).textTheme.displaySmall,
                          children: [
                            TextSpan(
                              text: 'showFullComment'.tr,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomWidget(BuildContext context) {
    return Obx(
      () {
        if (Get.find<UserService>().isMember.isFalse) {
          return Container();
        }
        if (controller.isNoMore.value) {
          return Container(
            alignment: Alignment.center,
            color: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: RichText(
              text: TextSpan(
                text: '🎉 ',
                style: const TextStyle(
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'communityNoMore'.tr,
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                ],
              ),
            ),
          );
        } else {
          return VisibilityDetector(
            key: const Key('communityBottomWidget'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && controller.isLoadingMore.value) {
                controller.fetchMoreFollowingPickedNews();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }
      },
    );
  }
}
