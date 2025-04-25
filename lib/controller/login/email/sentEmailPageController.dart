import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:readr/getxServices/environmentService.dart';

class SentEmailPageController extends GetxController {
  final String email;
  SentEmailPageController({required this.email});

  Timer? _timer;
  final countdownSeconds = 60.obs;
  final canResend = false.obs;
  final isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    countdownSeconds.value = 60;
    canResend.value = false;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (countdownSeconds.value == 0) {
          timer.cancel();
          canResend.value = true;
        } else {
          countdownSeconds.value--;
        }
      },
    );
  }

  void resendEmail() async {
    if (isResending.value) return;

    isResending.value = true;

    try {
      bool isSuccess = await LoginHelper().signInWithEmailAndLink(
        email,
        Get.find<EnvironmentService>().config.authlink,
      );
      if (isSuccess) {
        Fluttertoast.showToast(
          msg: "驗證信已重新發送", // Hardcoded string
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
        // Restart timer after successful resend
        startTimer();
      } else {
        Fluttertoast.showToast(
          msg: "Email寄送失敗", // Hardcoded string
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error resending email: $e');
      Fluttertoast.showToast(
        msg: "發生錯誤: $e", // Hardcoded string
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    } finally {
      isResending.value = false;
    }
  }
}
