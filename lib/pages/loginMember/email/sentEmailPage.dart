import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:readr/controller/login/email/sentEmailPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

class SentEmailPage extends GetView<SentEmailPageController> {
  final String email;
  const SentEmailPage(this.email, {super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SentEmailPageController(email: email));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'sentEmailPageAppbarTitle'.tr,
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
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
            '${'sentEmailPagePrefix'.tr}\n ${controller.email}${'sentEmailPageSuffix'.tr}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary600!,
              fontSize: 17,
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
              var result = await OpenMailApp.openMailApp();
              if (!result.didOpen && !result.canOpen) {
                showNoMailAppsDialog(context);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
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
          child: _buildResendHint(context),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'tryOtherLoginMethod'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.underline,
              decorationColor:
                  Theme.of(context).extension<CustomColors>()!.primary700!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendHint(BuildContext context) {
    return Obx(() {
      final bool canResend = controller.canResend.value;
      final bool isResending = controller.isResending.value;
      final int countdown = controller.countdownSeconds.value;

      final resendStyle = TextStyle(
        color: canResend && !isResending
            ? Theme.of(context).extension<CustomColors>()!.primary700!
            : Theme.of(context).extension<CustomColors>()!.primary400!,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        decoration: canResend && !isResending ? TextDecoration.underline : null,
        decorationColor:
            Theme.of(context).extension<CustomColors>()!.primary700!,
      );

      final defaultStyle = TextStyle(
        color: Theme.of(context).extension<CustomColors>()!.primary400!,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

      return RichText(
        text: TextSpan(
          style: defaultStyle,
          children: [
            const TextSpan(text: '沒收到信件？ 請檢查垃圾信件匣\n'),
            const TextSpan(text: '或 '),
            TextSpan(
              text: '重新發送信件',
              style: resendStyle,
              recognizer: TapGestureRecognizer()
                ..onTap =
                    canResend && !isResending ? controller.resendEmail : null,
            ),
            if (!canResend) TextSpan(text: ' ($countdown秒)'),
          ],
        ),
        textAlign: TextAlign.center,
      );
    });
  }

  void showNoMailAppsDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text("找不到信件 APP"),
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
