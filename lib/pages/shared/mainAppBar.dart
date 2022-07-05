import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/mainAppBarController.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/invitationCode/invitationCodePage.dart';
import 'package:readr/pages/notify/notifyPage.dart';

class MainAppBar extends GetView<MainAppBarController> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0.5,
      title: SvgPicture.asset(
        appBarIconSvg,
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => NotifyPage(), fullscreenDialog: true),
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  GetPlatform.isAndroid
                      ? Icons.notifications_none_outlined
                      : CupertinoIcons.bell,
                  color: readrBlack,
                  size: 26,
                ),
                Obx(
                  () {
                    if (Get.find<NotifyPageController>()
                        .unReadNotifyList
                        .isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 1, right: 2),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
        Obx(
          () {
            if (Get.find<UserService>().isMember.isFalse) {
              return Container();
            }
            return IconButton(
              onPressed: () {
                Get.to(
                  () => InvitationCodePage(),
                  fullscreenDialog: true,
                );
              },
              icon: Obx(
                () => SvgPicture.asset(
                  controller.hasInvitationCode.value
                      ? newInvitationCodeSvg
                      : invitationCodeSvg,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
