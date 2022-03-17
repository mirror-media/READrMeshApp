import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_route/auto_route.dart';
import 'package:readr/blocs/login/login_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWidget extends StatefulWidget {
  final bool fromComment;
  final bool fromOnboard;
  const LoginWidget(this.fromComment, this.fromOnboard);
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          showToast("登入失敗");
        } else if (state is NewMemberSignup) {
          AutoRouter.of(context).push(
              InputNameRoute(publisherTitleList: state.publisherTitleList));
        } else if (state is ExistingMemberLogin) {
          AutoRouter.of(context)
              .pushAndPopUntil(const Initial(), predicate: (route) => false);
        }
      },
      child: _buildContent(),
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }

  void firebaseLoginSuccess(bool isNewUser) {
    BlocProvider.of<LoginCubit>(context).login(isNewUser);
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (widget.fromOnboard)
          const SizedBox(
            height: 20,
          ),
        if (!widget.fromOnboard)
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              widget.fromComment ? '立即登入以參與大家的討論' : '立即登入，享受更多個人化新聞選讀服務',
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (Platform.isIOS) ...[
          LoginButton(
            type: LoginType.apple,
            onSuccess: (bool isNewUser) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('loginType', 'apple');
              firebaseLoginSuccess(isNewUser);
            },
            onFailed: (error) {
              showToast("登入失敗");
            },
          ),
          const SizedBox(
            height: 12,
          ),
        ],
        LoginButton(
          type: LoginType.facebook,
          onSuccess: (bool isNewUser) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('loginType', 'facebook');
            firebaseLoginSuccess(isNewUser);
          },
          onFailed: (error) {
            showToast("登入失敗");
          },
        ),
        const SizedBox(
          height: 12,
        ),
        LoginButton(
          type: LoginType.google,
          onSuccess: (bool isNewUser) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('loginType', 'google');
            firebaseLoginSuccess(isNewUser);
          },
          onFailed: (error) {
            showToast("登入失敗");
          },
        ),
        const SizedBox(
          height: 12,
        ),
        OutlinedButton.icon(
          onPressed: () => context.pushRoute(const InputEmailRoute()),
          label: const Text(
            '以 Email 信箱繼續',
            style: TextStyle(
              color: readrBlack,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: const Icon(
            Icons.email_outlined,
            size: 18,
            color: readrBlack87,
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: readrBlack,
              width: 1,
            ),
            fixedSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        _statement(),
      ],
    );
  }

  Widget _statement() {
    String html =
        "<div style='text-align:center'>繼續使用代表您同意與接受</div><div style='text-align:center'>我們的<a href='https://www.readr.tw/privacy-rule'>《服務條款》</a>及<a href='https://www.readr.tw/privacy-rule'>《隱私政策》</div>";
    return HtmlWidget(
      html,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'text-decoration-color': 'rgba(0, 9, 40, 1)',
            'color': 'rgba(0, 9, 40, 1)',
            'text-decoration-thickness': '100%',
            'text-align': 'center',
          };
        }
        return null;
      },
      textStyle: const TextStyle(
        fontSize: 13,
        color: readrBlack30,
      ),
    );
  }
}
