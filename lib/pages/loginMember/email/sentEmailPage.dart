import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:readr/helpers/dataConstants.dart';

class SentEmailPage extends StatelessWidget {
  final String email;
  const SentEmailPage(this.email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '確認收件匣',
          style: TextStyle(
            color: readrBlack,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: readrBlack87,
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
            '我們已將登入連結寄到\n $email，請點擊信件中的連結登入。',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromRGBO(0, 9, 40, 0.66),
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
                            app.name == 'Apple Mail' ? '信件' : app.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '取消',
                        style: TextStyle(
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
              primary: readrBlack,
              backgroundColor: Colors.white,
              onSurface: readrBlack20,
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(
                color: readrBlack,
              ),
            ),
            child: const Text('打開信件 APP'),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Center(
          child: Text(
            '沒收到信件？請檢查垃圾信件匣',
            style: TextStyle(
              color: readrBlack30,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '或',
              style: TextStyle(
                color: readrBlack30,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '嘗試其他登入方式',
                softWrap: true,
                style: TextStyle(
                  color: readrBlack87,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: readrBlack87,
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
        title: const Text("找不到信件 APP"),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text("確定"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
