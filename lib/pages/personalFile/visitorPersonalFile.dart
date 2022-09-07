import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/setting/settingPage.dart';

class VisitorPersonalFile extends StatelessWidget {
  const VisitorPersonalFile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.settings,
            color: readrBlack,
          ),
          onPressed: () {
            Get.to(() => SettingPage());
          },
        ),
        title: Text(
          'personalFileTab'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack87,
          ),
        ),
        centerTitle: GetPlatform.isIOS,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _visitorContent(),
    );
  }

  Widget _visitorContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 24),
          child: Text(
            'visitorContentTitle'.tr,
            style: const TextStyle(
              color: readrBlack87,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: () {
              Get.to(
                () => const LoginPage(),
                fullscreenDialog: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: readrBlack87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              'visitorContentButton'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
