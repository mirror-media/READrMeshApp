import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/services/memberService.dart';

class DeleteMemberPage extends StatefulWidget {
  @override
  _DeleteMemberPageState createState() => _DeleteMemberPageState();
}

class _DeleteMemberPageState extends State<DeleteMemberPage> {
  bool _isInitialized = true;
  bool _isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0.5,
          title: const Text(
            '刪除帳號',
            style: TextStyle(
              color: readrBlack,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: _isInitialized
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: readrBlack,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        body: SafeArea(
          child: _buildContent(),
        ),
      ),
      onWillPop: () async => _isInitialized,
    );
  }

  Widget _buildContent() {
    String email;
    if (UserHelper.instance.currentUser.email!.contains('[0x0001]')) {
      email = '您';
    } else {
      email = '${UserHelper.instance.currentUser.email} ';
    }
    String title = '真的要刪除帳號嗎？';
    String discription = '提醒您，$email 的帳號資訊（包含精選、書籤、留言）將永久刪除並無法復原。';
    String buttonText = '那我再想想';
    if (!_isInitialized && _isSuccess) {
      title = '刪除帳號成功';
      discription = '謝謝您使用我們的會員服務。如果您有需要，歡迎隨時回來 :)';
      buttonText = '回首頁';
    } else if (!_isInitialized && !_isSuccess) {
      title = '喔不，出錯了...';
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
              color: readrBlack87,
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
            textAlign: TextAlign.center,
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
                context.read<ConfigBloc>().add(LoginUpdate());
                AutoRouter.of(context).navigate(const Initial());
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              side: const BorderSide(
                color: readrBlack,
                width: 1,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: readrBlack,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 28,
        ),
        if (_isInitialized)
          TextButton(
            onPressed: () async {
              _isSuccess = await _deleteMember();
              setState(() {
                _isInitialized = false;
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

  Future<bool> _deleteMember() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      await MemberService().deleteMember();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must reauthenticate before this operation can be executed.');
      }
      return false;
    } catch (e) {
      print('Delete member failed: $e');
      return false;
    }
  }
}
