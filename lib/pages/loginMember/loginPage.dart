import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/loginPageController.dart';
import 'package:readr/helpers/themes.dart';
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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            appBarTitle,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()?.primary700,
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
                    icon: Icon(
                      Icons.close_outlined,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
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
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitWanderingCubes(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'loggingIn'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildContent(context);
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

  Widget _buildContent(BuildContext context) {
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
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary700,
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
            buttonBackgroundColor: Theme.of(context).backgroundColor,
            buttonBorderColor:
                Theme.of(context).extension<CustomColors>()!.primary700!,
            textColor: Theme.of(context).extension<CustomColors>()!.primary700!,
            loadingAnimationColor:
                Theme.of(context).extension<CustomColors>()!.primary200!,
            iconColor: Theme.of(context).brightness == Brightness.light
                ? null
                : Colors.white,
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
          buttonBackgroundColor: Theme.of(context).backgroundColor,
          buttonBorderColor:
              Theme.of(context).extension<CustomColors>()!.primary700!,
          textColor: Theme.of(context).extension<CustomColors>()!.primary700!,
          loadingAnimationColor:
              Theme.of(context).extension<CustomColors>()!.primary200!,
          iconColor: Theme.of(context).brightness == Brightness.light
              ? null
              : Colors.white,
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
          buttonBackgroundColor: Theme.of(context).backgroundColor,
          buttonBorderColor:
              Theme.of(context).extension<CustomColors>()!.primary700!,
          textColor: Theme.of(context).extension<CustomColors>()!.primary700!,
          loadingAnimationColor:
              Theme.of(context).extension<CustomColors>()!.primary200!,
          iconColor: Theme.of(context).brightness == Brightness.light
              ? null
              : Colors.white,
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
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: Icon(
            Icons.email_outlined,
            size: 18,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).backgroundColor,
            side: BorderSide(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              width: 1,
            ),
            fixedSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        _statement(context),
      ],
    );
  }

  Widget _statement(BuildContext context) {
    String html = "loginStatementHtml".tr;
    String urlColor = Theme.of(context).brightness == Brightness.light
        ? 'rgba(0, 9, 40, 0.87)'
        : 'rgba(246, 246, 251, 1)';
    return HtmlWidget(
      html,
      key: Key(Theme.of(context).brightness.toString()),
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'text-decoration-color': urlColor,
            'color': urlColor,
            'text-decoration-thickness': '100%',
            'text-align': 'center',
          };
        }
        return null;
      },
      textStyle: TextStyle(
        fontSize: 13,
        color: Theme.of(context).extension<CustomColors>()!.primary400!,
      ),
    );
  }
}
