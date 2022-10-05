import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/community/comment/commentBottomSheetWidget.dart';
import 'package:readr/services/commentService.dart';

class CommentBottomSheet {
  static Future<void> showCommentBottomSheet({
    required BuildContext context,
    required Comment clickComment,
    required PickObjective objective,
    required String id,
    required String controllerTag,
    String? oldContent,
  }) async {
    if (!Get.isRegistered<CommentController>(tag: controllerTag)) {
      Get.put<CommentController>(
        CommentController(
          commentRepos: CommentService(),
          objective: objective,
          id: id,
          controllerTag: controllerTag,
        ),
        tag: controllerTag,
      );
      Get.find<CommentController>(tag: controllerTag).fetchComments();
    }

    await showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(24),
      builder: (context) => Material(
        child: SafeArea(
          bottom: false,
          child: CommentBottomSheetWidget(
            clickComment: clickComment,
            oldContent: oldContent,
            controllerTag: controllerTag,
          ),
        ),
      ),
    ).whenComplete(() async {
      bool deleteController = true;
      // when there has text, show hint
      if (Get.find<CommentInputBoxController>(tag: controllerTag)
          .hasInput
          .isTrue) {
        deleteController = false;
        await showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text(
              'deleteAlertTitle'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 17),
            ),
            content: Text(
              'leaveAlertContent'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontSize: 13),
            ),
            actions: [
              PlatformDialogAction(
                onPressed: () {
                  deleteController = true;
                  Navigator.pop(context);
                },
                child: PlatformText(
                  'deleteComment'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).extension<CustomColors>()?.redText,
                  ),
                ),
              ),
              PlatformDialogAction(
                onPressed: () async {
                  Navigator.pop(context);
                  await showCommentBottomSheet(
                    context: context,
                    clickComment: clickComment,
                    objective: objective,
                    oldContent:
                        Get.find<CommentInputBoxController>(tag: controllerTag)
                            .textController
                            .text,
                    id: id,
                    controllerTag: controllerTag,
                  );
                },
                child: PlatformText(
                  'continueInput'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).extension<CustomColors>()?.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (deleteController) {
        for (var item
            in Get.find<CommentController>(tag: controllerTag).allComments) {
          Get.delete<CommentItemController>(tag: item.id);
        }

        Get.delete<CommentController>(tag: controllerTag);
        Get.delete<CommentInputBoxController>(tag: controllerTag);
      }
    });
  }
}
