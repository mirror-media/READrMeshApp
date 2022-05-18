import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/home/homePage.dart';
import 'package:readr/pages/personalFile/personalFileWidget.dart';
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
      HomePage(),
      ReadrPage(),
      PersonalFileWidget(
        viewMember: Get.find<UserService>().currentUser,
        isFromBottomTab: true,
        isMine: true,
        isVisitor: Get.find<UserService>().isVisitor,
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
          onTap: (index) {
            if (index == 2 && Get.find<UserService>().isMember) {
              context
                  .read<PersonalFileCubit>()
                  .fetchMemberData(Get.find<UserService>().currentUser);
            }
            controller.changeTabIndex(index);
          },
          selectedItemColor: bottomNavigationBarSelectedColor,
          unselectedItemColor: bottomNavigationBarUnselectedColor,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 20,
                child: SvgPicture.asset(
                  homeDefaultSvg,
                ),
              ),
              activeIcon: SizedBox(
                height: 20,
                child: SvgPicture.asset(
                  homeActiveSvg,
                ),
              ),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 20,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrDefaultSvg,
                ),
              ),
              activeIcon: Container(
                height: 20,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrActiveSvg,
                ),
              ),
              label: 'READr',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 20,
                child: Obx(
                  () {
                    if (controller.isVisitor.value) {
                      return Image.asset(
                        visitorAvatarPng,
                      );
                    } else {
                      return ProfilePhotoWidget(
                          Get.find<UserService>().currentUser, 11);
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
