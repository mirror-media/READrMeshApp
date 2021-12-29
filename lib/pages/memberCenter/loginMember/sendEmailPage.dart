import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';

class SendEmailPage extends StatelessWidget {
  final String email;
  const SendEmailPage(this.email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          '註冊 / 登入會員',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
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
      padding: const EdgeInsets.only(top: 48, left: 40, right: 40),
      physics: MediaQuery.of(context).orientation == Orientation.portrait
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [
        const Center(
          child: Text(
            '請確認收件匣',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Center(
          child: Text(
            '我們已將登入連結寄到 $email，請點擊信件中的連結登入。',
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
          margin: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: OutlinedButton(
            onPressed: () {
              context.navigateTo(const Initial(children: [ReadrRouter()]));
            },
            child: const Text('好的'),
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              fixedSize: const Size(113, 48),
              primary: Colors.black,
              backgroundColor: hightLightColor,
              onSurface: Colors.black26,
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
                  decorationColor: hightLightColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
