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
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/community/widget/community_item.dart';
import 'package:readr/pages/community/widget/bottom_widget.dart';
import 'package:readr/pages/community/widget/empty_widget.dart';

class CommunityPage extends GetView<CommunityController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isInitialized = controller.isInitialized.value;
        final isError = controller.isError.value;
        final errorValue = controller.rxError.value;

        if (!isInitialized) {
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

        if (isError) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              MainAppBar(),
              SliverFillRemaining(
                child: ErrorPage(
                  error: errorValue,
                  onPressed: () => controller.initPage(),
                  hideAppbar: true,
                ),
              ),
            ],
          );
        }

        return ScrollsToTop(
          onScrollsToTop: (event) async => controller.scrollToTopAndRefresh(),
          child: _buildBody(context),
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
                final communityList = controller.communityList;
                if (communityList.isEmpty) {
                  return EmptyWidget(controller: controller);
                }

                int end = 3;
                if (communityList.length < 3) {
                  end = communityList.length;
                }

                return _buildList(
                  context,
                  communityList.sublist(0, end),
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
                final recommendMembers = controller.recommendMembers;
                final communityList = controller.communityList;
                if (recommendMembers.isEmpty || communityList.isEmpty) {
                  return Container();
                }

                return Container(
                  color: Theme.of(context).backgroundColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RecommendFollowBlock(
                    RecommendMemberBlockController()
                      ..recommendMembers.assignAll(recommendMembers
                          .map((m) => MemberFollowableItem(m))
                          .toList()),
                    showTitleBar: true,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                final communityList = controller.communityList;
                if (communityList.length < 3) {
                  return Container();
                }

                return _buildList(
                  context,
                  communityList.sublist(3),
                  {
                    4: 'social_AT2',
                    10: 'social_AT3',
                    16: 'social_AT4',
                    22: 'social_AT5',
                    28: 'social_AT6',
                    34: 'social_AT7',
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BottomWidget(controller: controller),
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
              CommunityItem(
                item: communityList[index],
                controller: controller,
              ),
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

        return CommunityItem(
          item: communityList[index],
          controller: controller,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: communityList.length,
    );
  }
}
