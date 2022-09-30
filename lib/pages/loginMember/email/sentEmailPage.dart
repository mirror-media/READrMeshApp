import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

class SentEmailPage extends StatelessWidget {
  final String email;
  const SentEmailPage(this.email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'sentEmailPageAppbarTitle'.tr,
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Center(
          child: Text(
            '${'sentEmailPagePrefix'.tr}\n $email${'sentEmailPageSuffix'.tr}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primaryLv2!,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.center,
          child: OutlinedButton(
            onPressed: () async {
              // Android: Will open mail app or show native picker.
              // iOS: Will open mail app if single mail app found.
              var result = await OpenMailApp.openMailApp();

              // If no mail apps found, show error
              if (!result.didOpen && !result.canOpen) {
                showNoMailAppsDialog(context);

                // iOS: if multiple mail apps found, show dialog to select.
                // There is no native intent/default app system in iOS so
                // you have to do it yourself.
              } else if (!result.didOpen && result.canOpen) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    actions: [
                      for (var app in result.options)
                        CupertinoActionSheetAction(
                          onPressed: () {
                            OpenMailApp.openSpecificMailApp(app);
                            Navigator.pop(context);
                          },
                          child: Text(
                            app.name == 'Apple Mail'
                                ? 'appleMail'.tr
                                : app.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(
                color: meshBlack87,
              ),
            ),
            child: Text(
              'openEmailApp'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: meshBlack87,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Center(
          child: Text(
            'notReceiveText'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primaryLv4!,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'or'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv4!,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'tryOtherLoginMethod'.tr,
                softWrap: true,
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("noMailAppsDialogTitle".tr),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text("ok".tr),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
