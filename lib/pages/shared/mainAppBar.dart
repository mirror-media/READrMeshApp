import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/mainAppBarController.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/invitationCode/invitationCodePage.dart';
import 'package:readr/pages/notify/notifyPage.dart';
import 'package:readr/pages/search/searchPage.dart';

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
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 10.5),
          child: IconButton(
            onPressed: () => Get.to(() => SearchPage()),
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: Icon(
              PlatformIcons(context).search,
              size: 26,
              color: readrBlack87,
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 10.5),
          child: IconButton(
            onPressed: () => Get.to(() => NotifyPage(), fullscreenDialog: true),
            padding: const EdgeInsets.all(0),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  GetPlatform.isAndroid
                      ? Icons.notifications_none_outlined
                      : CupertinoIcons.bell,
                  color: readrBlack87,
                  size: 26,
                ),
                Obx(
                  () {
                    if (Get.find<NotifyPageController>()
                        .unReadNotifyList
                        .isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(left: 12, bottom: 12),
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
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(left: 9.5, right: 14),
          child: Obx(
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
                padding: const EdgeInsets.all(0),
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        CupertinoIcons.envelope,
                        color: readrBlack87,
                        size: 26,
                      ),
                    ),
                    Obx(
                      () {
                        if (controller.hasInvitationCode.isTrue) {
                          return Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(left: 18, bottom: 18),
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
              );
            },
          ),
        )
      ],
    );
  }
}
