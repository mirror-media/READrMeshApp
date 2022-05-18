import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/followableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/loginMember/loginPage.dart';

class FollowButton extends GetView<FollowableItemController> {
  final FollowableItem item;
  final bool expanded;
  final double textSize;
  const FollowButton(
    this.item, {
    this.expanded = false,
    this.textSize = 14,
  });

  @override
  String get tag => item.tag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FollowableItemController>(tag: tag)) {
      Get.put<FollowableItemController>(
        FollowableItemController(item),
        tag: tag,
      );
    }
    if (expanded) {
      return SizedBox(
        width: double.maxFinite,
        child: _buildButton(context),
      );
    }
    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    return Obx(
      () => OutlinedButton(
        onPressed: () async {
          if (item.type == 'member' && Get.find<UserService>().isVisitor) {
            Get.to(
              () => const LoginPage(),
              fullscreenDialog: true,
            );
          } else {
            controller.isFollowed.toggle();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: readrBlack87, width: 1),
          backgroundColor:
              controller.isFollowed.value ? readrBlack87 : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        ),
        child: Text(
          controller.isFollowed.value ? '追蹤中' : '追蹤',
          maxLines: 1,
          style: TextStyle(
            fontSize: textSize,
            color: controller.isFollowed.value ? Colors.white : readrBlack87,
          ),
        ),
      ),
    );
  }
}
