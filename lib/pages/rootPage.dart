import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/community/community_page.dart';
import 'package:readr/pages/community/community_binding.dart';
import 'package:readr/pages/latest/latestPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/personalFile/visitorPersonalFile.dart';
import 'package:readr/pages/readr/readrPage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/wallet/walletPage.dart';
import 'package:upgrader/upgrader.dart';

class RootPage extends GetView<RootPageController> {
  RootPage({super.key}) {
    CommunityBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RootPageController>(
      builder: (controller) {
        if (controller.isInitialized) {
          return UpgradeAlert(
            upgrader: Upgrader(
              minAppVersion: controller.minAppVersion,
              messages: UpdateMessages(),
              dialogStyle: Platform.isAndroid
                  ? UpgradeDialogStyle.material
                  : UpgradeDialogStyle.cupertino,
            ),
            child: _buildBody(context),
          );
        }
        return Container(
          color: const Color.fromRGBO(4, 13, 44, 1),
          child: Image.asset(
            splashIconPng,
            scale: 4,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    List<Widget> bodyList = [
      CommunityPage(),
      LatestPage(),
      ReadrPage(),
      Obx(
        () {
          if (Get.find<UserService>().isMember.isTrue) {
            return PersonalFilePage(
              viewMember: Get.find<UserService>().currentUser,
              isFromBottomTab: true,
            );
          }

          return const VisitorPersonalFile();
        },
      ),
      WalletPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          elevation: 10,
          selectedFontSize: 12,
          currentIndex: controller.tabIndex.value,
          onTap: (index) => controller.changeTabIndex(index),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Icon(
                  CupertinoIcons.bubble_left_bubble_right,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
                ),
              ),
              activeIcon: SizedBox(
                height: 24,
                child: Icon(
                  CupertinoIcons.bubble_left_bubble_right_fill,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                ),
              ),
              label: 'communityTab'.tr,
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Icon(
                  latestpage,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
                ),
              ),
              activeIcon: SizedBox(
                height: 24,
                child: Icon(
                  latestpageFill,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                ),
              ),
              label: 'latestTab'.tr,
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 24,
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.light
                      ? meshBlack30
                      : meshGray50,
                ),
                child: Icon(
                  readrLogo,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                ),
              ),
              activeIcon: Container(
                height: 24,
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                ),
                child: Icon(
                  readrLogo,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                ),
              ),
              label: 'READr',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Obx(
                  () {
                    if (Get.find<UserService>().isMember.isFalse) {
                      return Icon(
                        CupertinoIcons.person_solid,
                        size: 20,
                        color: Theme.of(context).primaryColorDark,
                      );
                    } else {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfilePhotoWidget(
                            Get.find<UserService>().currentUser,
                            11,
                            hideBorder: true,
                          ),
                          Obx(
                            () {
                              if (controller.haveNewFeature.isTrue) {
                                return Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(
                                    left: 14,
                                    bottom: 12,
                                  ),
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
                      );
                    }
                  },
                ),
              ),
              label: 'personalFileTab'.tr,
            ),
            // BottomNavigationBarItem(
            //   icon: SizedBox(
            //     height: 24,
            //     child: Icon(
            //       Icons.account_balance_wallet_outlined,
            //       color: Theme.of(context)
            //           .bottomNavigationBarTheme
            //           .unselectedItemColor,
            //     ),
            //   ),
            //   activeIcon: SizedBox(
            //     height: 24,
            //     child: Icon(
            //       Icons.account_balance_wallet,
            //       color: Theme.of(context)
            //           .bottomNavigationBarTheme
            //           .selectedItemColor,
            //     ),
            //   ),
            //   label: '錢包',
            // ),
          ],
        ),
      ),
      body: Obx(
        () => bodyList[controller.tabIndex.value],
      ),
    );
  }
}
