import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
      centerTitle: false,
      title: Icon(
        meshLogo,
        size: 32,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      actions: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 10.5),
          child: IconButton(
            onPressed: () => Get.to(() => SearchPage()),
            padding: const EdgeInsets.all(0),
            tooltip: 'searchButtonTooltip'.tr,
            alignment: Alignment.centerRight,
            icon: Icon(
              PlatformIcons(context).search,
              size: 26,
              color: Theme.of(context).appBarTheme.foregroundColor,
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
            tooltip: 'notificationButtonTooltip'.tr,
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  GetPlatform.isAndroid
                      ? Icons.notifications_none_outlined
                      : CupertinoIcons.bell,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  size: 26,
                ),
                Obx(
                  () {
                    if (Get.find<NotifyPageController>()
                        .unReadNotifyList
                        .isNotEmpty) {
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(243, 75, 75, 0.5),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(243, 75, 75, 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
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
                tooltip: 'invitationCodeButtonTooltip'.tr,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        CupertinoIcons.envelope,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        size: 26,
                      ),
                    ),
                    Obx(
                      () {
                        if (controller.hasInvitationCode.isTrue) {
                          return Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(243, 75, 75, 0.5),
                                    blurRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(243, 75, 75, 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
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
