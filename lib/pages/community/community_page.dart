import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/mainAppBar.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:readr/pages/community/community_controller.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/pages/community/widget/community_item.dart';
import 'package:readr/pages/community/widget/bottom_widget.dart';
import 'package:readr/pages/community/widget/empty_widget.dart';
import 'package:readr/data/enum/page_status.dart';

class CommunityPage extends GetView<CommunityController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (!controller.rxIsInitialized.value) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              MainAppBar(),
              SliverFillRemaining(
                child: HomeSkeletonScreen(),
              ),
            ],
          );
        }

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

        return Stack(
          children: [
            ScrollsToTop(
              onScrollsToTop: (event) async =>
                  controller.scrollToTopAndRefresh(),
              child: _buildBody(context),
            ),
            Obx(() {
              return controller.rxPageStatus.value == PageStatus.loading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A40),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
          ],
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.updateCommunityPage();
        return;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller.scrollController,
        slivers: [
          MainAppBar(),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.rxCommunityList.isEmpty) {
                  return EmptyWidget(
                    recommendMembers:
                        controller.getRecommendMemberFollowableItems(),
                  );
                }

                return _buildList(
                  context,
                  controller.getHeaderCommunityList(),
                  {},
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.rxCommunityList.isEmpty) {
                  return Container();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NativeAdWidget(
                      key: const Key('social_AT1'),
                      adHeight: context.width * 0.82,
                      topWidget: const SizedBox(height: 8),
                      adBgColor: Theme.of(context).backgroundColor,
                      factoryId: 'full',
                      adUnitIdKey: 'social_AT1',
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (!(controller.rxRecommendMembers.isNotEmpty &&
                    controller.rxCommunityList.isNotEmpty)) {
                  return Container();
                }

                return Container(
                  color: Theme.of(context).backgroundColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RecommendFollowBlock(
                    RecommendMemberBlockController()
                      ..recommendMembers.assignAll(
                          controller.getRecommendMemberFollowableItems()),
                    showTitleBar: true,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (!(controller.rxCommunityList.length > 3)) {
                  return Container();
                }

                return _buildList(
                  context,
                  controller.getRemainingCommunityList(),
                  {
                    4: 'social_AT2',
                    9: 'social_AT3',
                    14: 'social_AT4',
                    19: 'social_AT5',
                    24: 'social_AT6',
                    29: 'social_AT7',
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BottomWidget(
              isMember: controller.userService.isMember,
              isNoMore: controller.rxIsNoMore,
              onVisibilityChanged: controller.handleVisibilityChanged,
            ),
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
        final item = communityList[index];
        return CommunityItem(
          item: item,
          firstItemId: controller.rxCommunityList.isNotEmpty
              ? controller.rxCommunityList.first.itemId
              : null,
          onMoreAction: (item) => controller.handleMoreAction(context, item),
          onTapItem: controller.handleTapItem,
          onTapAuthor: controller.handleTapAuthor,
        );
      },
      separatorBuilder: (context, index) {
        if (adIndexAndId.containsKey(index)) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NativeAdWidget(
                key: Key(adIndexAndId[index]!),
                adHeight: context.width * 0.82,
                topWidget: const SizedBox(height: 8),
                adBgColor: Theme.of(context).backgroundColor,
                factoryId: 'full',
                adUnitIdKey: adIndexAndId[index]!,
              ),
              const SizedBox(height: 8),
            ],
          );
        }
        return const SizedBox(height: 8);
      },
      itemCount: communityList.length,
    );
  }
}
