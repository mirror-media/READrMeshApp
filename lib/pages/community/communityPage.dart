import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/community/comment/commentBottomSheet.dart';
import 'package:readr/pages/community/latestComment/latestCommentsBlock.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/homeAppBar.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowItem.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CommunityPage extends GetView<CommunityPageController> {
  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      controller.initPage();
    } else {
      controller.updateCommunityPage();
    }
    return Scaffold(
      backgroundColor: homeScreenBackgroundColor,
      body: GetBuilder<CommunityPageController>(
        builder: (controller) {
          if (controller.isError) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                const HomeAppBar(),
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

          if (!controller.isLoading) {
            return _buildBody(context);
          }

          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              const HomeAppBar(),
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
        slivers: [
          const HomeAppBar(),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.followingPickedNews.isEmpty) {
                  return _emptyWidget();
                }

                int end = 3;
                if (controller.followingPickedNews.length < 3) {
                  end = controller.followingPickedNews.length;
                }

                return _buildPickedNewsList(
                    context, controller.followingPickedNews.sublist(0, end));
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
                    .isEmpty) {
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
                if (controller.followingPickedNews.length < 3) {
                  return Container();
                }

                int end = 6;
                if (controller.followingPickedNews.length < 6) {
                  end = controller.followingPickedNews.length;
                }

                return _buildPickedNewsList(
                    context, controller.followingPickedNews.sublist(3, end));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: LatestCommentsBlock(),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.followingPickedNews.length < 6) {
                  return Container();
                }

                return _buildPickedNewsList(
                    context, controller.followingPickedNews.sublist(6));
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
          const Text(
            '咦？這裡好像還缺點什麼...',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          RichText(
            text: const TextSpan(
                text: '追蹤您喜愛的人\n看看他們都精選了什麼新聞',
                style: TextStyle(
                  color: readrBlack50,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: ' 👀',
                    style: TextStyle(
                      fontSize: 16,
                      color: readrBlack,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 32,
          ),
          Obx(
            () {
              if (recommendMemberBlockController.recommendMembers.isNotEmpty) {
                return SizedBox(
                  height: 230,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 20),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => RecommendFollowItem(
                        recommendMemberBlockController.recommendMembers[index]),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemCount:
                        recommendMemberBlockController.recommendMembers.length,
                  ),
                );
              }
              return Container();
            },
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPickedNewsList(
      BuildContext context, List<NewsListItem> newsList) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      itemBuilder: (context, index) =>
          _followingItem(context, newsList[index], Get.width / 2),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: newsList.length,
    );
  }

  Widget _followingItem(
      BuildContext context, NewsListItem item, double height) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pickBar(context, item.followingPickMembers),
          InkWell(
            onTap: () {
              Get.to(
                () => StoryPage(
                  news: item,
                ),
                fullscreenDialog: true,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.heroImageUrl != null)
                  CachedNetworkImage(
                    imageUrl: item.heroImageUrl!,
                    placeholder: (context, url) => SizedBox(
                      width: double.infinity,
                      height: height,
                      child: Shimmer.fromColors(
                        baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                        highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                        child: Container(
                          width: double.infinity,
                          height: height,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(),
                    imageBuilder: (context, imageProvider) {
                      return Image(
                        image: imageProvider,
                        width: double.infinity,
                        height: height,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: Text(
                    item.source.title,
                    style: const TextStyle(color: readrBlack50, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 20, right: 20, bottom: 8),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: readrBlack87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: NewsInfo(item),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PickBar(item.controllerTag),
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
                await CommentBottomSheet.showCommentBottomSheet(
                  context: context,
                  clickComment: item.showComment!,
                  objective: PickObjective.story,
                  id: item.id,
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

  Widget _pickBar(BuildContext context, List<Member> members) {
    if (members.isEmpty) {
      return Container();
    }
    List<Member> firstTwoMember = [];
    for (int i = 0; i < members.length && i < 2; i++) {
      firstTwoMember.add(members[i]);
    }

    List<Widget> children = [
      ProfilePhotoStack(
        firstTwoMember,
        14,
        key: UniqueKey(),
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
            style: const TextStyle(fontSize: 14, color: readrBlack87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '精選了這篇',
        style: TextStyle(fontSize: 14, color: readrBlack50),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '及',
        style: TextStyle(fontSize: 14, color: readrBlack50),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '都精選了這篇',
        style: TextStyle(fontSize: 14, color: readrBlack50),
        maxLines: 1,
      ));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: children,
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
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          style: const TextStyle(
                            color: readrBlack87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: readrBlack20,
                      ),
                    ),
                    Timestamp(comment.publishDate),
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
                    joinZeroWidthSpace: true,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.end,
                      child: RichText(
                        text: const TextSpan(
                          text: '... ',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 9, 40, 0.66),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: '看完整留言',
                              style: TextStyle(
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
        if (controller.isNoMore.isTrue) {
          return Container(
            alignment: Alignment.center,
            color: homeScreenBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: RichText(
              text: const TextSpan(
                text: '🎉 ',
                style: TextStyle(
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '你已追完所有更新囉',
                    style: TextStyle(
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
