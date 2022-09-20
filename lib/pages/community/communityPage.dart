import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/community/comment/commentBottomSheet.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/mainAppBar.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CommunityPage extends GetView<CommunityPageController> {
  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized) {
      controller.initPage();
    }
    return Scaffold(
      backgroundColor: homeScreenBackgroundColor,
      body: GetBuilder<CommunityPageController>(
        builder: (controller) {
          if (controller.isError) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                MainAppBar(),
                SliverFillRemaining(
                  child: ErrorPage(
                    error: controller.error,
                    onPressed: () => controller.initPage(),
                    hideAppbar: true,
                  ),
                ),
              ],
            );
          }

          if (controller.isInitialized) {
            return ScrollsToTop(
              onScrollsToTop: (event) async =>
                  controller.scrollToTopAndRefresh(),
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
                  return _emptyWidget();
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
                if (Get.find<RecommendMemberBlockController>()
                        .recommendMembers
                        .isEmpty ||
                    controller.communityList.isEmpty) {
                  return Container();
                }

                return Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RecommendFollowBlock(
                      Get.find<RecommendMemberBlockController>()),
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
            child: _bottomWidget(),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget() {
    final recommendMemberBlockController =
        Get.find<RecommendMemberBlockController>();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(87.5, 22, 87.5, 26),
            child: SvgPicture.asset(noFollowingSvg),
          ),
          Text(
            'communityEmptyTitle'.tr,
            style: const TextStyle(
              color: readrBlack87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              text: 'communityEmptyDescription'.tr,
              style: const TextStyle(
                color: readrBlack50,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: const [
                TextSpan(
                  text: ' 👀',
                  style: TextStyle(
                    fontSize: 16,
                    color: readrBlack,
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
                adBgColor: Colors.white,
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
      color: Colors.white,
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
                    item.heroImageWidget,
                    if (item.type != CommunityListItemType.commentStory &&
                        item.type != CommunityListItemType.pickStory)
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
                    child: item.authorTextWidget,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 20, right: 20, bottom: 8),
                  child: item.titleWidget,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: item.infoWidget,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PickBar(
              item.controllerTag,
              showPickTooltip:
                  item.itemId == controller.communityList.first.itemId,
            ),
          ),
          if (item.showComment != null) ...[
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Colors.black12,
              height: 1,
              thickness: 0.5,
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
          !firstTwoMember.any(
              (element) => element.memberId == item.itemBarMember[i].memberId),
          item.itemBarMember[i]);
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
            style: const TextStyle(fontSize: 14, color: readrBlack87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(Text(
        item.itemBarText,
        style: const TextStyle(fontSize: 14, color: readrBlack50),
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
            style: const TextStyle(fontSize: 14, color: readrBlack87),
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
        style: const TextStyle(fontSize: 14, color: readrBlack50),
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
            style: const TextStyle(fontSize: 14, color: readrBlack87),
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
        style: const TextStyle(fontSize: 14, color: readrBlack50),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
      ));
    }

    return Container(
      color: Colors.white,
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

              if (item.type == CommunityListItemType.pickStory ||
                  item.type == CommunityListItemType.commentStory) {
                objective = PickObjective.story;
                url = item.newsListItem!.url;
              } else {
                objective = PickObjective.collection;
                url = await DynamicLinkHelper.createCollectionLink(
                    item.collection!);
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
              color: readrBlack66,
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
      color: Colors.white,
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
                          style: TextStyle(
                            color: readrBlack87,
                            fontSize: 14,
                            fontWeight: GetPlatform.isIOS
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: readrBlack20,
                      ),
                    ),
                    Timestamp(
                      comment.publishDate,
                      key: ObjectKey(comment),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.5, bottom: 20),
                  child: ExtendedText(
                    comment.content,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 9, 40, 0.66),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
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
                          style: const TextStyle(
                            color: Color.fromRGBO(0, 9, 40, 0.66),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: 'showFullComment'.tr,
                              style: const TextStyle(
                                color: readrBlack50,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
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

  Widget _bottomWidget() {
    return Obx(
      () {
        if (Get.find<UserService>().isMember.isFalse) {
          return Container();
        }
        if (controller.isNoMore.isTrue) {
          return Container(
            alignment: Alignment.center,
            color: homeScreenBackgroundColor,
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
                    style: const TextStyle(
                      color: readrBlack30,
                      fontSize: 14,
                    ),
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
              if (visiblePercentage > 50 && controller.isLoadingMore.isFalse) {
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
