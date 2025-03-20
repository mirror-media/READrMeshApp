import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/addToCollectionPage.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showMoreActionSheet({
  required BuildContext context,
  required PickObjective objective,
  required String? id,
  required String controllerTag,
  String? url,
  String? heroImageUrl,
  NewsListItem? newsListItem,
}) async {
  if (id == null) {
    print('Warning: showMoreActionSheet called with null id');
    return;
  }

  await showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    topRadius: const Radius.circular(24),
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => Material(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Theme.of(context).backgroundColor,
                ),
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary400,
                  ),
                ),
              ),
            ),
            if (objective == PickObjective.story && newsListItem != null)
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  if (Get.find<UserService>().isMember.isFalse) {
                    Get.to(
                      () => const LoginPage(),
                      fullscreenDialog: true,
                    );
                  } else {
                    Get.to(
                      () => AddToCollectionPage(newsListItem),
                      fullscreenDialog: true,
                    );
                  }
                },
                icon: Icon(
                  PlatformIcons(context).folderOpen,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  size: 18,
                ),
                label: Text(
                  'addToCollection'.tr,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
            if (objective == PickObjective.story)
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  if (Get.find<UserService>().isMember.isFalse) {
                    Get.to(
                      () => const LoginPage(),
                      fullscreenDialog: true,
                    );
                  } else {
                    Get.find<PickableItemController>(tag: controllerTag)
                        .isBookmarked
                        .toggle();
                    Get.find<PickableItemController>(tag: controllerTag)
                        .updateBookmark();
                  }
                },
                icon: Icon(
                  Get.find<PickableItemController>(tag: controllerTag)
                          .isBookmarked
                          .value
                      ? PlatformIcons(context).bookmarkSolid
                      : PlatformIcons(context).bookmarkOutline,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  size: 18,
                ),
                label: Text(
                  Get.find<PickableItemController>(tag: controllerTag)
                          .isBookmarked
                          .value
                      ? 'removeBookmark'.tr
                      : 'addBookmark'.tr,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
            if (url != null)
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: url));
                  showMeshToast(
                      icon: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      message: 'copiedLink'.tr);
                },
                icon: Icon(
                  GetPlatform.isAndroid ? Icons.link : CupertinoIcons.link,
                  size: 19,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                ),
                label: Text(
                  'copyLink'.tr,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
            if (url != null)
              TextButton.icon(
                onPressed: () async {
                  Share.shareWithResult(url).then((value) {
                    if (value.status == ShareResultStatus.success) {
                      logShare(
                          objective.toString().split('.').last, id, value.raw);
                    }
                  });
                  Navigator.pop(context);
                },
                icon: Icon(
                  PlatformIcons(context).share,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  size: 18,
                ),
                label: Text(
                  'share'.tr,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  alignment: Alignment.centerLeft,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
