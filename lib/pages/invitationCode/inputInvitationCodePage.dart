import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:url_launcher/url_launcher.dart';

class InputInvitationCodePage extends StatefulWidget {
  const InputInvitationCodePage({Key? key}) : super(key: key);

  @override
  State<InputInvitationCodePage> createState() =>
      _InputInvitationCodePageState();
}

class _InputInvitationCodePageState extends State<InputInvitationCodePage> {
  final _formKey = GlobalKey<FormState>();
  final InvitationCodeService _invitationCodeService = InvitationCodeService();
  final _pinController = TextEditingController();
  late InvitationCodeStatus _status;
  bool _isComplete = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '邀請碼',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: readrBlack,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        actions: [
          if (_isComplete)
            TextButton(
              onPressed: () async {
                _loadingDialog(context);
                _status = await _invitationCodeService
                    .checkInvitationCode(_pinController.text);
                if (_status == InvitationCodeStatus.valid) {
                  Navigator.pop(context);
                  AutoRouter.of(context).replace(LoginRoute(fromOnboard: true));
                } else {
                  Navigator.pop(context);
                  _formKey.currentState!.validate();
                }
              },
              child: const Text(
                '送出',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    const _defaultPinTheme = PinTheme(
      width: 40,
      height: 32,
      textStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: readrBlack87,
      ),
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(0, 9, 40, 0.66),
          ),
        ),
      ),
    );
    final _focusedPinTheme = _defaultPinTheme.copyDecorationWith(
      border: const Border(
        bottom: BorderSide(
          color: Color.fromRGBO(0, 9, 40, 0.1),
        ),
      ),
    );
    final _errorPinTheme = _defaultPinTheme.copyDecorationWith(
      border: const Border(
        bottom: BorderSide(
          color: Colors.red,
        ),
      ),
    );
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(43, 40, 43, 0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Pinput(
              pinputAutovalidateMode: PinputAutovalidateMode.disabled,
              crossAxisAlignment: CrossAxisAlignment.center,
              controller: _pinController,
              onChanged: (value) {
                _status = InvitationCodeStatus.valid;
                _formKey.currentState!.validate();
              },
              validator: (code) {
                switch (_status) {
                  case InvitationCodeStatus.valid:
                    return null;
                  case InvitationCodeStatus.invalid:
                    return '邀請碼輸入錯誤，請重新輸入';
                  case InvitationCodeStatus.activated:
                    return '此邀請碼已被使用，請重新輸入';
                  case InvitationCodeStatus.error:
                    return '發生錯誤，請再試一次';
                }
              },
              onCompleted: (text) {
                setState(() {
                  _isComplete = true;
                });
              },
              errorTextStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              autofocus: true,
              enableSuggestions: false,
              keyboardType: TextInputType.text,
              length: 6,
              showCursor: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
              ],
              defaultPinTheme: _defaultPinTheme,
              followingPinTheme: _focusedPinTheme,
              errorPinTheme: _errorPinTheme,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'READr Mesh App 公開測試中，請向發行人取得邀請碼以繼續使用。\n',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: readrBlack50,
              ),
              children: [
                const TextSpan(
                  text: '如邀請碼有使用異常之狀況，請聯繫 ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: readrBlack50,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: 'readr@readr.tw',
                        queryParameters: {
                          'subject': '邀請碼問題',
                        },
                      );
                      String url = params.toString();
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Could not launch $url');
                      }
                    },
                    child: const Text(
                      'readr@readr.tw',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: readrBlack50,
                        decoration: TextDecoration.underline,
                        decorationColor: readrBlack50,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: ' 詢問。',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: readrBlack50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _loadingDialog(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
    showDialog(
      //prevent outside touch
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        //prevent Back button press
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: alert);
      },
    );
  }
}
