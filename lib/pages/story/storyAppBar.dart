import 'package:easy_debounce/easy_debounce.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/addToCollectionPage.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:share_plus/share_plus.dart';

class StoryAppBar extends GetView<StoryPageController> {
  final NewsListItem news;
  const StoryAppBar(this.news);

  @override
  String get tag => news.id;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: ExtendedText(
        controller.newsListItem.url,
        joinZeroWidthSpace: true,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
      ),
      actions: <Widget>[
        GetBuilder<StoryPageController>(
          tag: news.id,
          builder: (controller) {
            if (controller.isLoading || controller.isError) {
              return Container();
            }

            return IconButton(
              icon: Icon(
                PlatformIcons(context).folderOpen,
                color: Theme.of(context).appBarTheme.foregroundColor,
                size: 26,
              ),
              tooltip: 'addToCollection'.tr,
              onPressed: () {
                if (Get.find<UserService>().isMember.isFalse) {
                  Get.to(
                    () => const LoginPage(),
                    fullscreenDialog: true,
                  );
                } else {
                  Get.to(
                    () => AddToCollectionPage(news),
                    fullscreenDialog: true,
                  );
                }
              },
            );
          },
        ),
        GetBuilder<StoryPageController>(
          tag: news.id,
          builder: (controller) {
            if (controller.isLoading || controller.isError) {
              return Container();
            }

            return Obx(
              () {
                return IconButton(
                  icon: Icon(
                    Get.find<PickableItemController>(tag: news.controllerTag)
                            .isBookmarked
                            .value
                        ? PlatformIcons(context).bookmarkSolid
                        : PlatformIcons(context).bookmarkOutline,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    size: 26,
                  ),
                  tooltip:
                      Get.find<PickableItemController>(tag: news.controllerTag)
                              .isBookmarked
                              .value
                          ? 'removeBookmark'.tr
                          : 'addBookmark'.tr,
                  onPressed: () async {
                    if (Get.find<UserService>().isMember.isFalse) {
                      Get.to(
                        () => const LoginPage(),
                        fullscreenDialog: true,
                      );
                    } else {
                      Get.find<PickableItemController>(tag: news.controllerTag)
                          .isBookmarked
                          .toggle();
                      EasyDebounce.debounce(
                        'UpdateBookmark${news.id}',
                        const Duration(milliseconds: 500),
                        () => Get.find<PickableItemController>(
                                tag: news.controllerTag)
                            .updateBookmark(),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
        GetBuilder<StoryPageController>(
          tag: news.id,
          builder: (controller) {
            if (controller.isLoading || controller.isError) {
              return Container();
            }

            return IconButton(
              icon: Icon(
                PlatformIcons(context).share,
                color: Theme.of(context).appBarTheme.foregroundColor,
                size: 26,
              ),
              tooltip: 'share'.tr,
              onPressed: () {
                Share.shareWithResult(controller.newsListItem.url)
                    .then((value) {
                  if (value.status == ShareResultStatus.success) {
                    logShare('story', controller.newsListItem.id, value.raw);
                  }
                });
              },
            );
          },
        ),
        IconButton(
          icon: Icon(
            PlatformIcons(context).clear,
            color: Theme.of(context).appBarTheme.foregroundColor,
            size: 26,
          ),
          tooltip: 'back'.tr,
          onPressed: () async {
            if (Get.isRegistered<CommentInputBoxController>(
                    tag: news.controllerTag) &&
                Get.find<CommentInputBoxController>(tag: news.controllerTag)
                    .hasInput
                    .isTrue) {
              await showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                  title: Text(
                    'deleteAlertTitle'.tr,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  content: Text(
                    'leaveAlertContent'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  actions: [
                    PlatformDialogAction(
                      onPressed: () => Get.close(2),
                      child: PlatformText(
                        'deleteComment'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context)
                              .extension<CustomColors>()
                              ?.redText,
                        ),
                      ),
                    ),
                    PlatformDialogAction(
                      onPressed: () => Get.back(),
                      child: PlatformText(
                        'continueInput'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          color:
                              Theme.of(context).extension<CustomColors>()?.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }
}
