import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/editCollection/editDescriptionPage.dart';
import 'package:readr/pages/collection/editCollection/reorderPage.dart';
import 'package:readr/pages/collection/editCollection/editTitlePage.dart';
import 'package:share_plus/share_plus.dart';

class CollectionAppBar extends GetView<CollectionPageController>
    implements PreferredSizeWidget {
  final Collection collection;
  const CollectionAppBar(this.collection);

  @override
  String get tag => collection.id;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: GetPlatform.isIOS,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack,
        ),
        onPressed: () async {
          if (Get.isRegistered<CommentInputBoxController>(
                  tag: collection.controllerTag) &&
              Get.find<CommentInputBoxController>(tag: collection.controllerTag)
                  .hasInput
                  .isTrue) {
            await showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: const Text(
                  '確定要刪除留言？',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: const Text(
                  '系統將不會儲存您剛剛輸入的內容',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                actions: [
                  PlatformDialogAction(
                    onPressed: () => Get.back(closeOverlays: true),
                    child: PlatformText(
                      '刪除留言',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  PlatformDialogAction(
                    onPressed: () => Get.back(),
                    child: PlatformText(
                      '繼續輸入',
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
      title: const Text(
        '集錦',
        style: TextStyle(
          fontSize: 18,
          color: readrBlack,
        ),
      ),
      actions: [
        GetBuilder<CollectionPageController>(
          tag: collection.id,
          builder: (controller) {
            if (!controller.isError && !controller.isLoading) {
              return IconButton(
                icon: Icon(
                  PlatformIcons(context).share,
                  color: readrBlack87,
                  size: 26,
                ),
                tooltip: '分享',
                onPressed: () async {
                  String shareLink =
                      await DynamicLinkHelper.createCollectionLink(collection);
                  Share.shareWithResult(shareLink).then((value) {
                    if (value.status == ShareResultStatus.success) {
                      logShare('collection', collection.id, value.raw);
                    }
                  });
                },
              );
            }

            return Container();
          },
        ),
        GetBuilder<CollectionPageController>(
          tag: collection.id,
          builder: (controller) {
            if (!controller.isError && !controller.isLoading) {
              return Obx(
                () {
                  if (Get.find<UserService>().isMember.isTrue &&
                      collection.creator.memberId ==
                          Get.find<UserService>().currentUser.memberId) {
                    return IconButton(
                      onPressed: () async =>
                          await _showEditCollectionBottomSheet(context),
                      icon: Icon(
                        PlatformIcons(context).ellipsis,
                        color: readrBlack87,
                        size: 26,
                      ),
                    );
                  }
                  return Container();
                },
              );
            }

            return Container();
          },
        ),
      ],
    );
  }

  Future<void> _showEditCollectionBottomSheet(BuildContext context) async {
    String? result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('title'),
            child: const Text(
              '修改標題',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('description'),
            child: const Text(
              '修改敘述',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('edit'),
            child: const Text(
              '編輯內容',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: const Text(
              '刪除集錦',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Color.fromRGBO(255, 59, 48, 1),
              ),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text(
            '取消',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
    if (result == 'title') {
      Get.to(
        () => EditTitlePage(
          collection: collection,
        ),
        fullscreenDialog: true,
      );
    } else if (result == 'description') {
      Get.to(
        () => EditDescriptionPage(
          collection: collection,
          description: controller.collectionDescription.value,
        ),
      );
    } else if (result == 'edit') {
      Get.to(
        () => ReorderPage(
          collection: collection,
        ),
        fullscreenDialog: true,
      );
    } else if (result == 'delete') {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(
            '確認刪除集錦？',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '此動作無法復原',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                controller.deleteCollection();
                Get.back();
              },
              child: Text(
                '刪除',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
