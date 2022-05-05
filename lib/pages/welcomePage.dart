import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/invitationCode/inputInvitationCodePage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SvgPicture.asset(
                  welcomeScreenLogoSvg,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 107),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.off(() => const InputInvitationCodePage()),
                    child: const Text(
                      '開始使用',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: readrBlack87,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        }
        return false;
      },
    );
  }
}
