import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/rootPage.dart';

class DeleteMemberPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0.5,
          title: Text(
            'deletePageTitle'.tr,
            style: const TextStyle(
              color: readrBlack,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: GetBuilder<SettingPageController>(builder: (controller) {
            if (controller.isInitial) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: readrBlack,
                ),
                onPressed: () => Navigator.of(context).pop(),
              );
            }
            return Container();
          }),
        ),
        body: Obx(() {
          if (controller.isDeleting.isFalse) {
            return _buildContent();
          }

          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'deletingAccount'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      color: readrBlack,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      onWillPop: () async => controller.isInitial,
    );
  }

  Widget _buildContent() {
    String discription;
    if (Get.find<UserService>().currentUser.email!.contains('[0x0001]')) {
      discription = 'noEmailDescription'.tr;
    } else {
      String email = '${Get.find<UserService>().currentUser.email} ';
      if (Get.locale?.languageCode == 'en') {
        discription =
            "Remind you that $email's information (including picks, bookmarks, comments) will be permanently deleted and cannot be recovered.";
      } else if (Get.locale == const Locale('zh', 'CN')) {
        discription = '提醒您，$email 的帐户资讯（包含精选、书签、评论）将永久删除并无法复原。';
      } else {
        discription = '提醒您，$email 的帳號資訊（包含精選、書籤、留言）將永久刪除並無法復原。';
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 48, left: 40, right: 40),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          alignment: Alignment.center,
          child: GetBuilder<SettingPageController>(
            builder: (controller) {
              String title = 'deleteAccountDefaultTitle'.tr;
              if (!controller.isInitial && controller.deleteSuccess) {
                title = 'deleteAccountSuccessTitle'.tr;
              } else if (!controller.isInitial && !controller.deleteSuccess) {
                title = 'deleteAccountFailedTitle'.tr;
              }
              return Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color: readrBlack87,
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          alignment: Alignment.center,
          child: GetBuilder<SettingPageController>(
            builder: (controller) {
              if (!controller.isInitial && controller.deleteSuccess) {
                discription = 'deleteAccountSuccessDescription'.tr;
              } else if (!controller.isInitial && !controller.deleteSuccess) {
                discription = 'deleteAccountFailedDescription'.tr;
              }
              return Text(
                discription,
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: GetBuilder<SettingPageController>(
            builder: (controller) {
              String buttonText = 'letMeThinkAgain'.tr;
              if (!controller.isInitial) {
                buttonText = 'backToHomePage'.tr;
              }
              return OutlinedButton(
                onPressed: () async {
                  if (!controller.isInitial) {
                    await Get.find<UserService>().fetchUserData();
                    Get.offAll(() => RootPage());
                  } else {
                    Get.back();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  side: const BorderSide(
                    color: readrBlack,
                    width: 1,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: readrBlack,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 28,
        ),
        GetBuilder<SettingPageController>(builder: (controller) {
          if (controller.isInitial) {
            return Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  controller.deleteMember();
                },
                child: Text(
                  'confirmDeleteAccount'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }
          return Container();
        }),
      ],
    );
  }
}
