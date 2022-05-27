import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readr/controller/login/inputNamePageController.dart';
import 'package:readr/helpers/dataConstants.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: Platform.isIOS,
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            '暱稱',
            style: TextStyle(
              color: readrBlack,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: readrBlack,
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
                  child: const Text(
                    '完成註冊',
                    style: TextStyle(
                      color: Colors.blue,
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
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    '建立帳號中',
                    style: TextStyle(
                      fontSize: 20,
                      color: readrBlack,
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '請輸入暱稱。';
              } else if (!_validateNickname(value)) {
                return '這個暱稱目前無法使用，請使用其他暱稱。';
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: readrBlack87, width: 1.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: readrBlack10, width: 1.0),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: readrBlack10, width: 1.0),
              ),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        const Text(
          '請輸入您想使用的公開顯示名稱，字數以20字內為限。',
          style: TextStyle(
            fontSize: 13,
            color: readrBlack50,
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
