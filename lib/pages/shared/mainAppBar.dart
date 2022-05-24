import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/mainAppBarController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/invitationCode/invitationCodePage.dart';

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
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(
        //     Icons.notifications_none_outlined,
        //     color: readrBlack,
        //   ),
        // )
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
