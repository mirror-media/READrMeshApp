import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/readr/readrTabController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/readrProjectItemWidget.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';
import 'package:readr/services/tabStoryListService.dart';

class ReadrTabContent extends GetView<ReadrTabController> {
  final String categorySlug;
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
          padding: const EdgeInsets.only(top: 20),
          separatorBuilder: (context, index) {
            if (controller.readrMixedList[index].isProject) {
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
                indent: 20,
                endIndent: 20,
              ),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            if (index == controller.readrMixedList.length) {
              return _loadMoreWidget();
            }

            if (controller.readrMixedList[index].isProject) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ReadrProjectItemWidget(
                  controller.readrMixedList[index].newsListItem,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NewsListItemWidget(
                controller.readrMixedList[index].newsListItem,
                hidePublisher: true,
              ),
            );
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
                text: const TextSpan(
                  text: '🎉 ',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '你已看完所有新聞囉',
                      style: TextStyle(
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
