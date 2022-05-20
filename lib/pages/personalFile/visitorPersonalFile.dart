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
        title: const Text(
          '個人檔案',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
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
        const Padding(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 24),
          child: Text(
            '建立帳號，客製化追蹤更多優質新聞',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
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
              primary: readrBlack87,
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
            child: const Text(
              '立即建立',
              style: TextStyle(
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
