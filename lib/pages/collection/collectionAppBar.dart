import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/getxServices/internetCheckService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/editCollection/reorderPage.dart';
import 'package:readr/pages/collection/editCollection/titleAndOg/editTitlePage.dart';
import 'package:share_plus/share_plus.dart';

class CollectionAppBar extends GetView<CollectionPageController> {
  final Collection collection;
  const CollectionAppBar(this.collection);

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: UniqueKey(),
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
        IconButton(
          icon: Icon(
            PlatformIcons(context).share,
            color: readrBlack87,
            size: 26,
          ),
          tooltip: '分享',
          onPressed: () async {
            String shareLink =
                await DynamicLinkHelper.createCollectionLink(collection);
            Share.share(shareLink);
          },
        ),
        Obx(
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
        )
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
                if (await Get.find<InternetCheckService>()
                    .meshCheckInstance
                    .hasConnection) {
                  controller.deleteCollection();
                } else {
                  Fluttertoast.showToast(
                    msg: "連線失敗 請稍後再試",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }

                Get.back();
              },
              child: const Text(
                '刪除',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
