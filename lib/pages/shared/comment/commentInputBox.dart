import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class CommentInputBox extends GetView<CommentInputBoxController> {
  final String? oldContent;
  final String commentControllerTag;
  const CommentInputBox({
    required this.commentControllerTag,
    this.oldContent,
  });

  @override
  String get tag => commentControllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommentInputBoxController>(
        tag: commentControllerTag)) {
      Get.put(
        CommentInputBoxController(
          oldContent: oldContent,
          commentControllerTag: commentControllerTag,
        ),
        tag: commentControllerTag,
      );
    }

    return Obx(() {
      if (Get.find<UserService>().isMember.isFalse) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                Get.to(
                  () => const LoginPage(
                    fromComment: true,
                  ),
                  fullscreenDialog: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).extension<CustomColors>()?.primaryLv1,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                'commentVisitorHint'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              ProfilePhotoWidget(Get.find<UserService>().currentUser, 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 52),
                  Expanded(
                    child: Obx(() {
                      Color textFieldTextColor = Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv1!;
                      if (Get.find<CommentController>(tag: commentControllerTag)
                          .isSending
                          .isTrue) {
                        textFieldTextColor = Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv5!;
                      }
                      return TextField(
                        minLines: 1,
                        maxLines: 4,
                        readOnly: Get.find<CommentController>(
                                tag: commentControllerTag)
                            .isSending
                            .value,
                        style: TextStyle(
                          color: textFieldTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        controller: controller.textController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'commentTextFieldHint'.tr,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontSize: 16),
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    if (controller.hasInput.isFalse) {
                      return Container();
                    }
                    return TextButton(
                      onPressed: _sendComment,
                      child: Obx(() {
                        Color sendTextColor =
                            Theme.of(context).extension<CustomColors>()!.blue!;
                        if (controller.hasInput.isFalse) {
                          sendTextColor = Theme.of(context).backgroundColor;
                        } else if (Get.find<CommentController>(
                                tag: commentControllerTag)
                            .isSending
                            .isTrue) {
                          sendTextColor = readrBlack20;
                        }
                        return Text(
                          'sendComment'.tr,
                          style: TextStyle(
                            color: sendTextColor,
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _sendComment() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool result = await Get.find<CommentController>(tag: commentControllerTag)
        .addComment(controller.textController.text);
    if (result) {
      controller.textController.clear();
    }
  }
}
