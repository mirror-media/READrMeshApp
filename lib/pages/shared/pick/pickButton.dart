import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/internetCheckService.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';

class PickButton extends StatelessWidget {
  final String controllerTag;
  final bool expanded;
  final double textSize;
  final bool isInMyPersonalFile;
  const PickButton(
    this.controllerTag, {
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
    final controller = Get.find<PickableItemController>(tag: controllerTag);
    return Obx(
      () => OutlinedButton(
        onPressed: () async {
          if (Get.find<UserService>().isMember.isFalse) {
            Get.to(
              () => const LoginPage(),
              fullscreenDialog: true,
            );
          } else if (controller.isLoading.isFalse) {
            if (controller.isPicked.isFalse) {
              await PickBottomSheet.showPickBottomSheet(
                context: context,
                controller: controller,
              );
            } else {
              bool? result = await showDialog<bool>(
                context: context,
                builder: (context) => PlatformAlertDialog(
                  title: const Text(
                    '確認移除精選？',
                  ),
                  content: Get.find<PickAndBookmarkService>().pickList.any(
                          (element) =>
                              element.targetId == controller.targetId &&
                              element.objective == controller.objective)
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
                      onPressed: () async {
                        if (await Get.find<InternetCheckService>()
                            .meshCheckInstance
                            .hasConnection) {
                          Navigator.pop<bool>(context, true);
                        } else {
                          Fluttertoast.showToast(
                            msg: "伺服器連接失敗 請稍後再試",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                    ),
                    PlatformDialogAction(
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop<bool>(context, false),
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
                String? pickId = Get.find<PickAndBookmarkService>()
                    .pickList
                    .firstWhereOrNull(
                      (element) =>
                          element.targetId == controller.targetId &&
                          element.objective == controller.objective,
                    )
                    ?.myPickId;
                controller.deletePick();
                if (isInMyPersonalFile && pickId != null) {
                  await Future.delayed(const Duration(milliseconds: 50));
                  Get.find<PickTabController>(
                          tag: Get.find<UserService>().currentUser.memberId)
                      .unPick(pickId);
                }
              }
            }
          } else if (controller.isLoading.isTrue) {
            Fluttertoast.showToast(
              msg: "更新伺服器中 請稍候",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: readrBlack87, width: 1),
          backgroundColor:
              controller.isPicked.value ? readrBlack87 : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.isPicked.value
                  ? Icons.done_outlined
                  : Icons.add_outlined,
              size: textSize + 4,
              color: controller.isPicked.value ? Colors.white : readrBlack87,
            ),
            const SizedBox(width: 3),
            Text(
              controller.isPicked.value ? '已精選' : '精選',
              style: TextStyle(
                fontSize: textSize,
                color: controller.isPicked.value ? Colors.white : readrBlack87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
