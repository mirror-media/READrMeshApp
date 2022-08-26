import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/helpers/dataConstants.dart';

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
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: Text(
              'deleteComment'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: Text(
            'cancel'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
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
      builder: (context) => Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: readrBlack20,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop('edit'),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: readrBlack87,
                  size: 18,
                ),
                label: Text(
                  'editComment'.tr,
                  style: const TextStyle(
                    color: readrBlack87,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop('delete'),
                icon: const Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                  size: 18,
                ),
                label: Text(
                  'deleteComment'.tr,
                  style: const TextStyle(
                    color: Colors.red,
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    await showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(
          'deleteAlertTitle'.tr,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
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
                color: Colors.red,
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
