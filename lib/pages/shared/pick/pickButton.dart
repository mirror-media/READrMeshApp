import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';

class PickButton extends GetView<PickableItemController> {
  final String controllerTag;
  final bool expanded;
  final double textSize;
  final bool isInMyPersonalFile;
  final bool showPickTooltip;

  const PickButton(
    this.controllerTag, {
    this.expanded = false,
    this.textSize = 14,
    this.isInMyPersonalFile = false,
    this.showPickTooltip = false,
  });

  @override
  String get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    Widget button;
    double xOffset;

    if (expanded) {
      button = SizedBox(
        width: double.maxFinite,
        child: _buildButton(context),
      );
      xOffset = -40;
    } else {
      button = _buildButton(context);
      xOffset = 18;
    }

    final JustTheController tooltipController = JustTheController();
    if (showPickTooltip && Get.find<UserService>().showPickTooltip) {
      Future.delayed(const Duration(seconds: 1), () {
        try {
          tooltipController.showTooltip();
        } catch (e) {
          // Ignore controller not been attached error.
        }
      });
    }

    return JustTheTooltip(
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          '精選喜歡的報導',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF007AFF),
      preferredDirection: AxisDirection.up,
      margin: const EdgeInsets.only(left: 20),
      tailLength: 8,
      tailBaseWidth: 12,
      tailBuilder: (tip, point2, point3) => Path()
        ..moveTo(tip.dx + xOffset, tip.dy)
        ..lineTo(point2.dx + xOffset, point2.dy)
        ..lineTo(point3.dx + xOffset, point3.dy)
        ..close(),
      controller: tooltipController,
      shadow: const Shadow(color: Color.fromRGBO(0, 122, 255, 0.2)),
      onDismiss: () {
        Get.find<UserService>().showPickTooltip = false;
        Get.find<SharedPreferencesService>()
            .prefs
            .setBool('showPickTooltip', false);
      },
      child: button,
    );
  }

  Widget _buildButton(BuildContext context) {
    return Obx(
      () => OutlinedButton(
        onPressed: () async {
          if (Get.find<UserService>().isMember.isFalse) {
            Get.to(
              () => const LoginPage(),
              fullscreenDialog: true,
            );
          } else if (controller.isPicked.isFalse) {
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
                      Navigator.pop<bool>(context, true);
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
              controller.deletePick();
              if (isInMyPersonalFile) {
                await Future.delayed(const Duration(milliseconds: 50));
                Get.find<PickTabController>(
                        tag: Get.find<UserService>().currentUser.memberId)
                    .unPick(controller.objective, controller.targetId);
              }
            }
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
