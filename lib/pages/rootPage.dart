import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/community/communityPage.dart';
import 'package:readr/pages/latest/latestPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/personalFile/visitorPersonalFile.dart';
import 'package:readr/pages/readr/readrPage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:upgrader/upgrader.dart';

class RootPage extends GetView<RootPageController> {
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
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          elevation: 10,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          currentIndex: controller.tabIndex.value,
          onTap: (index) => controller.changeTabIndex(index),
          selectedItemColor: bottomNavigationBarSelectedColor,
          unselectedItemColor: bottomNavigationBarUnselectedColor,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.bubble_left_bubble_right,
                size: 20,
              ),
              activeIcon: Icon(
                CupertinoIcons.bubble_left_bubble_right_fill,
                size: 20,
              ),
              label: '社群',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.news,
                size: 20,
              ),
              activeIcon: Icon(
                CupertinoIcons.news_solid,
                size: 20,
              ),
              label: '最新',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 20,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrPageDefaultSvg,
                ),
              ),
              activeIcon: Container(
                height: 20,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrPageActiveSvg,
                ),
              ),
              label: 'READr',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 20,
                child: Obx(
                  () {
                    if (Get.find<UserService>().isMember.isFalse) {
                      return const Icon(
                        CupertinoIcons.person_solid,
                        size: 20,
                        color: readrBlack87,
                      );
                    } else {
                      return ProfilePhotoWidget(
                        Get.find<UserService>().currentUser,
                        11,
                        hideBorder: true,
                      );
                    }
                  },
                ),
              ),
              label: '個人檔案',
            ),
          ],
        ),
      ),
      body: Obx(
        () => bodyList[controller.tabIndex.value],
      ),
    );
  }
}
