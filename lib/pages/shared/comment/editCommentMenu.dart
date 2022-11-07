import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/helpers/themes.dart';

import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/comment/editCommentWidget.dart';

Future<void> showEditCommentMenu(
  BuildContext context,
  Comment comment,
  String controllerTag, {
  bool isFromPickTab = false,
}) async {
  String? result;
  if (GetPlatform.isIOS) {
    result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('edit'),
            child: Text(
              'editComment'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Theme.of(context).extension<CustomColors>()?.blue,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: Text(
              'deleteComment'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Theme.of(context).extension<CustomColors>()?.blue,
            ),
          ),
        ),
      ),
    );
  } else {
    result = await showCupertinoModalBottomSheet<String>(
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
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv4,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop('edit'),
                icon: Icon(
                  Icons.edit_outlined,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  size: 18,
                ),
                label: Text(
                  'editComment'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w400),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop('delete'),
                icon: Icon(
                  Icons.delete_outlined,
                  color: Theme.of(context).extension<CustomColors>()?.red,
                  size: 18,
                ),
                label: Text(
                  'deleteComment'.tr,
                  style: TextStyle(
                    color: Theme.of(context).extension<CustomColors>()?.redText,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (result == 'edit') {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: EditCommentWidget(comment),
        );
      },
    );
  } else if (result == 'delete') {
    Widget? dialogContent;

    final pickAndBookmarkService = Get.find<PickAndBookmarkService>();
    if (pickAndBookmarkService.pickList
        .any((element) => element.myPickCommentId == comment.id)) {
      dialogContent = Text(
        'deleteAlertContent'.tr,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    await showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(
          'deleteAlertTitle'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: dialogContent,
        actions: [
          PlatformDialogAction(
            onPressed: () {
              if (isFromPickTab) {
                Get.find<PickTabController>()
                    .deletePickComment(comment.id, controllerTag);
              } else {
                Get.find<CommentController>(tag: controllerTag)
                    .deleteComment(comment.id);
              }
              Navigator.pop(context);
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.redText,
                fontSize: 15,
                fontWeight:
                    GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.blue,
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
