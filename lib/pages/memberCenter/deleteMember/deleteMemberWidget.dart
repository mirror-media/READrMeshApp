import 'dart:io';

import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:auto_route/auto_route.dart';
import 'package:readr/helpers/router/router.dart';

class DeleteMemberWidget extends StatefulWidget {
  final Member member;
  const DeleteMemberWidget({required this.member});
  @override
  _DeleteMemberWidgetState createState() => _DeleteMemberWidgetState();
}

class _DeleteMemberWidgetState extends State<DeleteMemberWidget> {
  bool _isInitialized = true;
  bool _isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        //systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        title: const Text(
          '刪除帳號',
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    String email = widget.member.email;
    String title = '確定要刪除帳號嗎？';
    String discription = '提醒您，$email 的帳號資訊將永久刪除並無法復原。';
    String buttonText = '那我再想想';
    if (!_isInitialized && _isSuccess) {
      title = '刪除帳號成功';
      discription = '謝謝您使用 READr 的會員服務。如果您有需要，歡迎隨時回來 :)';
      buttonText = '回首頁';
    } else if (!_isInitialized && !_isSuccess) {
      title = '啊，出錯了...';
      discription = '刪除帳號失敗。請重新登入，或是聯繫客服信箱 readr@gmail.com 由專人為您服務。';
      buttonText = '回首頁';
    }
    return ListView(
      padding: const EdgeInsets.only(top: 48, left: 40, right: 40),
      physics: MediaQuery.of(context).orientation == Orientation.portrait
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            discription,
            softWrap: true,
            maxLines: 5,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(0, 9, 40, 0.66),
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
              if (_isInitialized) {
                Navigator.of(context).pop();
              } else {
                context.navigateTo(const Initial(children: [HomeRouter()]));
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 28,
        ),
        if (_isInitialized)
          TextButton(
            onPressed: () {
              setState(() {
                _isInitialized = false;
                _isSuccess = true;
              });
            },
            child: const Text(
              '確認刪除',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
