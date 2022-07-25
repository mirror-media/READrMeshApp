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
          title: const Text(
            '刪除帳號',
            style: TextStyle(
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
              children: const [
                SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    '刪除帳號中',
                    style: TextStyle(
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
    String email;
    if (Get.find<UserService>().currentUser.email!.contains('[0x0001]')) {
      email = '您';
    } else {
      email = '${Get.find<UserService>().currentUser.email} ';
    }

    return ListView(
      padding: const EdgeInsets.only(top: 48, left: 40, right: 40),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          alignment: Alignment.center,
          child: GetBuilder<SettingPageController>(
            builder: (controller) {
              String title = '真的要刪除帳號嗎？';
              if (!controller.isInitial && controller.deleteSuccess) {
                title = '刪除帳號成功';
              } else if (!controller.isInitial && !controller.deleteSuccess) {
                title = '喔不，出錯了...';
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
              String discription = '提醒您，$email 的帳號資訊（包含精選、書籤、留言）將永久刪除並無法復原。';
              if (!controller.isInitial && controller.deleteSuccess) {
                discription = '謝謝您使用我們的會員服務。如果您有需要，歡迎隨時回來 :)';
              } else if (!controller.isInitial && !controller.deleteSuccess) {
                discription = '刪除帳號失敗。請重新登入，或是聯繫客服信箱 readr@readr.tw 由專人為您服務。';
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
              String buttonText = '那我再想想';
              if (!controller.isInitial) {
                buttonText = '回首頁';
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
                child: const Text(
                  '確認刪除',
                  style: TextStyle(
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
