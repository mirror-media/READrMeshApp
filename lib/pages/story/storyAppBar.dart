import 'package:easy_debounce/easy_debounce.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: ExtendedText(
        controller.newsListItem.url,
        joinZeroWidthSpace: true,
        style: const TextStyle(
          color: readrBlack87,
          fontSize: 13,
        ),
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
                color: readrBlack87,
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
                    color: readrBlack87,
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
                color: readrBlack87,
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
            color: readrBlack87,
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'leaveAlertContent'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  actions: [
                    PlatformDialogAction(
                      onPressed: () => Get.close(2),
                      child: PlatformText(
                        'deleteComment'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    PlatformDialogAction(
                      onPressed: () => Get.back(),
                      child: PlatformText(
                        'continueInput'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
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
