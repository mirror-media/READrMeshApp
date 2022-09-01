import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/initControllerBinding.dart';
import 'package:readr/i18n/i18nHelper.dart';
import 'package:readr/pages/rootPage.dart';

class ReadrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    logAppOpen();
    return GetMaterialApp(
      title: 'READr Mesh',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      initialBinding: InitControllerBinding(),
      home: RootPage(),
      locale: Get.find<UserService>().appLocaleSetting,
      fallbackLocale: const Locale('en', 'US'),
      translations: I18nHelper(),
    );
  }
}
