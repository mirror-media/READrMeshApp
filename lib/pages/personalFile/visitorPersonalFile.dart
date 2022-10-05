import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/setting/settingPage.dart';

class VisitorPersonalFile extends StatelessWidget {
  const VisitorPersonalFile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
          onPressed: () {
            Get.to(() => SettingPage());
          },
        ),
        title: Text(
          'personalFileTab'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
        ),
        centerTitle: GetPlatform.isIOS,
        automaticallyImplyLeading: false,
      ),
      body: _visitorContent(context),
    );
  }

  Widget _visitorContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 24),
          child: Text(
            'visitorContentTitle'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
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
              backgroundColor:
                  Theme.of(context).extension<CustomColors>()!.primaryLv1!,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
