import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readr/controller/login/inputNamePageController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/services/memberService.dart';

class InputNamePage extends GetView<InputNamePageController> {
  final List<String> publisherTitleList;
  final bool isGoogle;
  InputNamePage(this.publisherTitleList, {this.isGoogle = false});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Get.put(InputNamePageController(
      memberRepos: MemberService(),
    ));
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          centerTitle: Platform.isIOS,
          elevation: 0,
          title: Text(
            'inputNamePageAppbarTitle'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
            ),
            onPressed: () async {
              if (controller.isCreating.isFalse) {
                await _cancelRegistration();
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Obx(() {
              if (controller.isCreating.isFalse) {
                return TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      controller.createMember();
                    }
                  },
                  child: Text(
                    'completeRegistration'.tr,
                    style: TextStyle(
                      color: Theme.of(context).extension<CustomColors>()!.blue!,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }
              return Container();
            }),
          ],
        ),
        body: Obx(() {
          if (controller.isCreating.isFalse) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildBody(context),
            );
          }

          return Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWanderingCubes(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'creatingAnAccount'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      onWillPop: () async {
        if (controller.isCreating.isTrue) {
          return false;
        }
        await _cancelRegistration();
        return true;
      },
    );
  }

  Future<void> _cancelRegistration() async {
    await FirebaseAuth.instance.currentUser?.delete();
    if (isGoogle && GetPlatform.isAndroid) {
      GoogleSignIn().disconnect();
    }
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.name,
            maxLength: 20,
            autovalidateMode: AutovalidateMode.disabled,
            controller: controller.textController,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).extension<CustomColors>()?.primary700,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'inputNamePageEmptyHint'.tr;
              } else if (!_validateNickname(value)) {
                return 'inputNamePageErrorHint'.tr;
              }
              return null;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary200!,
                  width: 1.0,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary200!,
                  width: 1.0,
                ),
              ),
              counterText: '',
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).extension<CustomColors>()!.red!,
                  width: 1.0,
                ),
              ),
              errorStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          'inputNamePageDescription'.tr,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<CustomColors>()!.primary500!,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  bool _validateNickname(String text) {
    for (var title in publisherTitleList) {
      if (_equalsIgnoreCase(text, title)) {
        return false;
      }
    }
    return true;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }
}
