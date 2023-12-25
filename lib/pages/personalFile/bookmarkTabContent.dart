import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/bookmarkTabController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/services/personalFileService.dart';

class BookmarkTabContent extends GetView<BookmarkTabController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookmarkTabController>(
      init: BookmarkTabController(PersonalFileService()),
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchBookmark(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          return Obx(
            () {
              if (controller.bookmarkList.isNotEmpty) {
                return _buildContent();
              } else {
                return _emptyWidget(context);
              }
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Text(
          'emptyBookmark'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()?.primary400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == controller.bookmarkList.length) {
            if (controller.isNoMore.isTrue) {
              return Container();
            }

            if (controller.isLoadingMore.isFalse) {
              controller.fetchMoreBookmark();
            }

            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return NewsListItemWidget(
            controller.bookmarkList[index].story!,
            key: Key(controller.bookmarkList[index].story!.id),
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.bookmarkList.length - 1) {
            return const SizedBox(
              height: 36,
            );
          }
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: controller.bookmarkList.length + 1,
      ),
    );
  }
}
