import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/mainAppBar.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LatestPage extends GetView<LatestPageController> {
  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized) {
      controller.initPage();
    }
    return Scaffold(
      backgroundColor: homeScreenBackgroundColor,
      body: GetBuilder<LatestPageController>(
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
      onRefresh: () async => await controller.updateLatestNewsPage(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller.scrollController,
        slivers: [
          MainAppBar(),
          _latestNewsBar(context),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.showLatestNews.isEmpty) {
                  return _emptyWidget();
                }

                int end = 5;
                if (controller.showLatestNews.length < 5) {
                  end = controller.showLatestNews.length;
                }

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildNewsList(
                    context,
                    controller.showLatestNews.sublist(0, end),
                    {2: 'listingnew_AT1'},
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (Get.find<RecommendPublisherBlockController>()
                        .recommendPublishers
                        .isEmpty ||
                    controller.showLatestNews.isEmpty) {
                  if (controller.showLatestNews.length >= 5) {
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 16, bottom: 20),
                      child: const Divider(
                        color: readrBlack10,
                        thickness: 1,
                        height: 1,
                        endIndent: 20,
                        indent: 20,
                      ),
                    );
                  }
                  return Container();
                }

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: RecommendFollowBlock(
                      Get.find<RecommendPublisherBlockController>()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.showLatestNews.length < 5) {
                  return Container();
                }

                return _buildNewsList(
                  context,
                  controller.showLatestNews
                      .sublist(5, controller.showLength.value),
                  {
                    2: 'listingnew_AT2',
                    8: 'listingnew_AT3',
                    12: 'listingnew_AT4',
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
    final recommendPublisherBlockController =
        Get.find<RecommendPublisherBlockController>();
    if (Get.find<UserService>().currentUser.followingPublisher.isEmpty) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(latestNewsEmptySvg, height: 91, width: 62),
            const SizedBox(
              height: 24,
            ),
            Text(
              'latestPageEmptyTitle'.tr,
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            RichText(
              text: TextSpan(
                  text: 'latestPageEmptyDescription'.tr,
                  style: const TextStyle(
                    color: readrBlack50,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(
                      text: ' 🗣',
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
              height: 20,
            ),
            RecommendFollowBlock(
              recommendPublisherBlockController,
              showTitleBar: false,
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(latestNewsEmptySvg, height: 91, width: 62),
            const SizedBox(
              height: 24,
            ),
            Text(
              'noArticlesTitle'.tr,
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            RichText(
              text: TextSpan(
                  text: 'noArticlesDescription'.tr,
                  style: const TextStyle(
                    color: readrBlack50,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(
                      text: ' 👇',
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
              height: 20,
            ),
            RecommendFollowBlock(
              recommendPublisherBlockController,
              showTitleBar: false,
            ),
          ],
        ),
      );
    }
  }

  Widget _latestNewsBar(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 1,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: () async {
          await _showFilterBottomSheet(context);
        },
        child: Row(
          children: [
            Text(
              'latestPageBar'.tr,
              style: TextStyle(
                  color: readrBlack87,
                  fontSize: 18,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more_outlined,
              color: readrBlack30,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(
    BuildContext context,
    List<NewsListItem> newsList,
    Map<int, String> adIndexAndId,
  ) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (adIndexAndId.containsKey(index)) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NewsListItemWidget(
                  newsList[index],
                  key: Key(newsList[index].id),
                ),
                NativeAdWidget(
                  key: Key(adIndexAndId[index]!),
                  factoryId: 'smallList',
                  adHeight: 76,
                  topWidget: const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 20),
                    child: Divider(
                      color: readrBlack10,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                  adUnitIdKey: adIndexAndId[index]!,
                ),
              ],
            );
          }
          return NewsListItemWidget(
            newsList[index],
            showPickTooltip: index == 0,
            key: Key(newsList[index].id),
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: newsList.length,
      ),
    );
  }

  Widget _bottomWidget() {
    return Obx(
      () {
        if (controller.showLatestNews.isEmpty) {
          return Container();
        } else if (controller.isNoMore.isTrue) {
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
                    text: 'latestPageBottomWidgetText'.tr,
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
            key: const Key('latestNewsBottomWidget'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && controller.isLoadingMore.isFalse) {
                controller.loadMore();
              }
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    bool showPaywall = controller.showPaywall;
    bool showFullScreenAd = controller.showFullScreenAd;
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(20),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Material(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.only(top: 16),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: readrBlack20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'latestPageFilterTitle'.tr,
                      style: const TextStyle(
                        color: readrBlack50,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: showPaywall,
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        showPaywall = value ?? controller.showPaywall;
                      });
                    },
                    activeColor: readrBlack87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: Text(
                      'paidArticle'.tr,
                      style: const TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: showFullScreenAd,
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        showFullScreenAd = value ?? controller.showFullScreenAd;
                      });
                    },
                    activeColor: readrBlack87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: Text(
                      'fullScreenAd'.tr,
                      style: const TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Divider(
                    color: readrBlack10,
                    height: 0.5,
                    thickness: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 17),
                    child: ElevatedButton(
                      onPressed: () async {
                        controller.showPaywall = showPaywall;
                        controller.showFullScreenAd = showFullScreenAd;
                        controller.updateFilter();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: readrBlack87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'filter'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
