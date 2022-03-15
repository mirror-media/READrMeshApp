import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';

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
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
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
                showDialog(
                  context: context,
                  builder: (_) {
                    return MailAppPickerDialog(
                      mailApps: result.options,
                    );
                  },
                );
              }
            },
            child: const Text('打開信件 APP'),
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              primary: Colors.black,
              backgroundColor: Colors.white,
              onSurface: Colors.black26,
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Center(
          child: Text(
            '沒收到信件？請檢查垃圾信件匣',
            style: TextStyle(
              color: Colors.black38,
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
                color: Colors.black38,
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
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("打開信件 APP"),
          content: const Text("找不到信件 APP"),
          actions: <Widget>[
            TextButton(
              child: const Text("確定"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
