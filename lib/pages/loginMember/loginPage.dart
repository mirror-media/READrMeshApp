import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/loginPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/email/inputEmailPage.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class LoginPage extends GetView<LoginPageController> {
  final bool fromComment;
  final bool fromOnboard;
  const LoginPage({this.fromComment = false, this.fromOnboard = false});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginPageController(
      invitationCodeRepos: InvitationCodeService(),
      personalFileRepos: PersonalFileService(),
      memberRepos: MemberService(),
    ));
    late final String appBarTitle;
    if (fromOnboard) {
      appBarTitle = 'loginOnboardAppbarTitle'.tr;
    } else if (fromComment) {
      appBarTitle = 'loginCommentAppbarTitle'.tr;
    } else {
      appBarTitle = 'loginAppbarTitle'.tr;
    }
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            appBarTitle,
            style: const TextStyle(
              color: readrBlack,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            if (!fromOnboard)
              Obx(
                () {
                  if (controller.isLoading.isTrue) {
                    return Container();
                  }

                  return IconButton(
                    icon: const Icon(
                      Icons.close_outlined,
                      color: readrBlack87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  );
                },
              ),
            // if (fromOnboard)
            //   TextButton(
            //     onPressed: () {
            //       AutoRouter.of(context).replace(const ChoosePublisherRoute());
            //     },
            //     child: const Text(
            //       '略過',
            //       style: TextStyle(
            //         color: Colors.blue,
            //         fontSize: 18,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //   ),
          ],
        ),
        body: Obx(
          () {
            if (controller.isLoading.isTrue) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitWanderingCubes(
                      color: readrBlack,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'loggingIn'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          color: readrBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildContent();
          },
        ),
      ),
      onWillPop: () async {
        if (controller.isLoading.isTrue) {
          return false;
        }
        if (fromOnboard) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          }
          return false;
        }
        return true;
      },
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

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (fromOnboard)
          const SizedBox(
            height: 20,
          ),
        if (!fromOnboard)
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              fromComment
                  ? 'loginPageContentFromComment'.tr
                  : 'loginPageContent'.tr,
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
            buttonText: 'continueWithApple'.tr,
            onFinished: (result, isNewUser, error) async {
              if (result == FirebaseLoginStatus.success) {
                controller.login(LoginType.apple, isNewUser);
              } else if (result == FirebaseLoginStatus.error) {
                showToast("loginFailed".tr);
              }
            },
          ),
          const SizedBox(
            height: 12,
          ),
        ],
        LoginButton(
          type: LoginType.facebook,
          buttonText: 'continueWithFacebook'.tr,
          onFinished: (result, isNewUser, error) async {
            if (result == FirebaseLoginStatus.success) {
              controller.login(LoginType.facebook, isNewUser);
            } else if (result == FirebaseLoginStatus.error) {
              showToast("loginFailed".tr);
            }
          },
        ),
        const SizedBox(
          height: 12,
        ),
        LoginButton(
          type: LoginType.google,
          buttonText: 'continueWithGoogle'.tr,
          onFinished: (result, isNewUser, error) async {
            if (result == FirebaseLoginStatus.success) {
              controller.login(LoginType.google, isNewUser);
            } else if (result == FirebaseLoginStatus.error) {
              showToast("loginFailed".tr);
            }
          },
        ),
        const SizedBox(
          height: 12,
        ),
        OutlinedButton.icon(
          onPressed: () => Get.to(InputEmailPage()),
          label: Text(
            'continueWithEmail'.tr,
            style: const TextStyle(
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
    String html = "loginStatementHtml".tr;
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
