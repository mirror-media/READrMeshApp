import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/dataConstants.dart';

class SetLanguagePage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    const languageSettingList = [
      LanguageSettings.system,
      LanguageSettings.traditionalChinese,
      LanguageSettings.simplifiedChinese,
      LanguageSettings.english,
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'setLanguage'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              _buildItem(context, languageSettingList[index]),
          separatorBuilder: (context, index) => const Divider(
            color: readrBlack10,
            height: 0.5,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          itemCount: 4,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, LanguageSettings languageSetting) {
    String text;
    switch (languageSetting) {
      case LanguageSettings.system:
        text = 'systemSetting'.tr;
        break;
      case LanguageSettings.traditionalChinese:
        text = '正體中文';
        break;
      case LanguageSettings.simplifiedChinese:
        text = '简体中文';
        break;
      case LanguageSettings.english:
        text = 'English';
        break;
    }
    return GestureDetector(
      onTap: () => controller.updateLanguage(languageSetting),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            Obx(
              () {
                if (controller.languageSetting.value == languageSetting) {
                  return const Icon(
                    Icons.check_outlined,
                    color: Colors.blue,
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
