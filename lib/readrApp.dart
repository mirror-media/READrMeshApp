import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/initControllerBinding.dart';
import 'package:readr/pages/rootPage.dart';

class ReadrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logAppOpen();
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
    );
  }
}
