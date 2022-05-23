import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';

class PickButton extends StatelessWidget {
  final String contorllerTag;
  final bool expanded;
  final double textSize;
  final bool isInMyPersonalFile;
  const PickButton(
    this.contorllerTag, {
    this.expanded = false,
    this.textSize = 14,
    this.isInMyPersonalFile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return SizedBox(
        width: double.maxFinite,
        child: _buildButton(context),
      );
    }

    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    final controller = Get.find<PickableItemController>(tag: contorllerTag);
    return Obx(
      () => OutlinedButton(
        onPressed: controller.isLoading.value
            ? null
            : () async {
                // check whether is login
                if (Get.find<UserService>().isMember.isTrue) {
                  if (controller.isPicked.isFalse) {
                    var result = await PickBottomSheet.showPickBottomSheet(
                      context: context,
                    );

                    if (result is String) {
                      controller.addPickAndComment(result);
                    } else if (result is bool && result) {
                      controller.addPick();
                    }
                  } else {
                    bool? result = await showDialog<bool>(
                      context: context,
                      builder: (context) => PlatformAlertDialog(
                        title: const Text(
                          '確認移除精選？',
                        ),
                        content: controller.myPickCommentId.value != null
                            ? const Text(
                                '移除精選文章，將會一併移除您的留言',
                              )
                            : null,
                        actions: [
                          PlatformDialogAction(
                            child: const Text(
                              '移除',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => Navigator.pop<bool>(context, true),
                          ),
                          PlatformDialogAction(
                            child: const Text(
                              '取消',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () =>
                                Navigator.pop<bool>(context, false),
                          )
                        ],
                        material: (context, target) => MaterialAlertDialogData(
                          titleTextStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          contentTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(109, 120, 133, 1),
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    );
                    if (result != null && result) {
                      String pickId = controller.myPickId.value!;
                      controller.deletePick();
                      if (isInMyPersonalFile) {
                        await Future.delayed(const Duration(milliseconds: 50));
                        Get.find<PickTabController>(
                                tag: Get.find<UserService>()
                                    .currentUser
                                    .memberId)
                            .unPick(pickId);
                      }
                    }
                  }
                } else {
                  Get.to(
                    () => const LoginPage(),
                    fullscreenDialog: true,
                  );
                }
              },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: readrBlack87, width: 1),
          backgroundColor:
              controller.isPicked.value ? readrBlack87 : Colors.white,
          padding: const EdgeInsets.fromLTRB(11, 3, 12, 4),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  controller.isPicked.value
                      ? Icons.done_outlined
                      : Icons.add_outlined,
                  size: textSize + 4,
                  color:
                      controller.isPicked.value ? Colors.white : readrBlack87,
                ),
              ),
              TextSpan(
                text: controller.isPicked.value ? '已精選' : '精選',
                style: TextStyle(
                  fontSize: textSize,
                  height: 1.9,
                  color:
                      controller.isPicked.value ? Colors.white : readrBlack87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
