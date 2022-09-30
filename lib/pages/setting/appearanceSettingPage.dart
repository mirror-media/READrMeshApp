import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

class AppearanceSettingPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    const appearanceSettingList = [
      AppearanceSettings.system,
      AppearanceSettings.light,
      AppearanceSettings.dark,
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'appearance'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _buildItem(context, appearanceSettingList[index]),
            separatorBuilder: (context, index) => const Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            itemCount: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, AppearanceSettings appearanceSetting) {
    String text;
    switch (appearanceSetting) {
      case AppearanceSettings.system:
        text = 'systemSetting'.tr;
        break;
      case AppearanceSettings.light:
        text = 'lightMode'.tr;
        break;
      case AppearanceSettings.dark:
        text = 'darkMode'.tr;
        break;
    }
    return GestureDetector(
      onTap: () => controller.updateAppearance(appearanceSetting),
      child: Container(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            Obx(
              () {
                if (controller.appearanceSetting.value == appearanceSetting) {
                  return Icon(
                    Icons.check_outlined,
                    color: Theme.of(context).extension<CustomColors>()!.blue!,
                    size: 16,
                  );
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
