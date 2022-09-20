import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/readr/readrTabController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/readrProjectItemWidget.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';
import 'package:readr/services/tabStoryListService.dart';

class ReadrTabContent extends GetView<ReadrTabController> {
  final String categorySlug;
  static const Map<int, String> _adIndexAndId = {
    2: 'listingREADr_320x100_AT1',
    7: 'listingREADr_320x100_AT2',
    13: 'listingREADr_320x100_AT3',
    17: 'listingREADr_320x100_AT4',
  };
  const ReadrTabContent({
    required this.categorySlug,
  });

  @override
  String get tag => categorySlug;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadrTabController>(
      init: ReadrTabController(
        categorySlug: categorySlug,
        tabStoryListRepos: TabStoryListServices(),
      ),
      tag: categorySlug,
      builder: (controller) {
        if (controller.isError) {
          final error = controller.error;

          return ErrorPage(
            error: error,
            onPressed: () => controller.fetchStoryList(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          if (controller.readrMixedList.isEmpty) {
            return TabContentNoResultWidget();
          }

          return _tabStoryList(context);
        }

        // state is Init, loading, or other
        return HomeSkeletonScreen();
      },
    );
  }

  Widget _tabStoryList(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(
        () => ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          separatorBuilder: (context, index) {
            if (controller.readrMixedList[index].isProject &&
                !_adIndexAndId.containsKey(index)) {
              return const SizedBox(
                height: 36,
              );
            }

            if (index + 1 < controller.readrMixedList.length) {
              if (controller.readrMixedList[index + 1].isProject) {
                return const SizedBox(
                  height: 36,
                );
              }
            }

            if (index == controller.readrMixedList.length - 1) {
              return Container();
            }

            return const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 20),
              child: Divider(
                color: readrBlack10,
                thickness: 0.5,
                height: 0.5,
              ),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            Widget content;
            if (index == controller.readrMixedList.length) {
              return _loadMoreWidget();
            }

            if (controller.readrMixedList[index].isProject) {
              content = ReadrProjectItemWidget(
                controller.readrMixedList[index].newsListItem,
              );
            } else {
              content = NewsListItemWidget(
                controller.readrMixedList[index].newsListItem,
                hidePublisher: true,
                key: Key(controller.readrMixedList[index].newsListItem.id),
              );
            }

            if (_adIndexAndId.containsKey(index)) {
              Widget topWidget;
              if (content is ReadrProjectItemWidget) {
                topWidget = const SizedBox(
                  height: 36,
                );
              } else {
                topWidget = const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 20),
                  child: Divider(
                    color: readrBlack10,
                    thickness: 0.5,
                    height: 0.5,
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  content,
                  NativeAdWidget(
                    key: Key(_adIndexAndId[index]!),
                    factoryId: 'smallList',
                    adHeight: 76,
                    topWidget: topWidget,
                    bottomWidget: const SizedBox(height: 4),
                    adUnitIdKey: _adIndexAndId[index]!,
                  ),
                ],
              );
            }

            return content;
          },
          itemCount: controller.readrMixedList.length + 1,
        ),
      ),
    );
  }

  Widget _loadMoreWidget() {
    return Obx(() {
      if (controller.noMore.isTrue) {
        return Column(
          children: [
            Container(
              height: 16,
              color: Colors.white,
            ),
            Container(
              color: homeScreenBackgroundColor,
              height: 20,
            ),
            Container(
              alignment: Alignment.center,
              color: homeScreenBackgroundColor,
              child: RichText(
                text: TextSpan(
                  text: '🎉 ',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'readrNoMore'.tr,
                      style: const TextStyle(
                        color: readrBlack30,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: homeScreenBackgroundColor,
              height: 145,
            ),
          ],
        );
      }

      if (controller.isLoadingMore.isFalse) {
        controller.fetchMoreStory();
      }

      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    });
  }
}
