import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          'invitationCode'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: Theme.of(context).appBarTheme.foregroundColor,
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
                  if (!mounted) return;
                  Navigator.pop(context);
                  Get.off(
                    () => const LoginPage(fromOnboard: true),
                    fullscreenDialog: true,
                  );
                } else {
                  if (!mounted) return;
                  Navigator.pop(context);
                  _formKey.currentState!.validate();
                }
              },
              child: Text(
                'send'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Theme.of(context).extension<CustomColors>()?.blue,
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
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 32,
      textStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Theme.of(context).extension<CustomColors>()?.primary700,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).extension<CustomColors>()!.primary600!,
          ),
        ),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
        ),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).extension<CustomColors>()!.red!,
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
                    return 'invitationCodeInputError'.tr;
                  case InvitationCodeStatus.activated:
                    return 'invitationCodeUsed'.tr;
                  case InvitationCodeStatus.error:
                    return 'invitationCodeError'.tr;
                }
              },
              onCompleted: (text) {
                setState(() {
                  _isComplete = true;
                });
              },
              errorTextStyle: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.redText!,
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
              defaultPinTheme: defaultPinTheme,
              followingPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'inputInvitationCodeDescriptionPrefix'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Theme.of(context).extension<CustomColors>()!.primaryLv3!,
              ),
              children: [
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

                      if (await canLaunchUrl(params)) {
                        await launchUrl(params);
                      } else {
                        print('Could not launch ${params.toString()}');
                      }
                    },
                    child: Text(
                      'readr@readr.tw',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv3!,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv3!,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: 'inputInvitationCodeDescriptionSuffix'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv3!,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
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
