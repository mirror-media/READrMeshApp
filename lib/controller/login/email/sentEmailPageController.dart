import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:readr/getxServices/environmentService.dart';

class SentEmailPageController extends GetxController {
  final String email = Get.arguments as String;
  SentEmailPageController();

  Timer? _timer;
  final rxCountdownSeconds = 60.obs;
  final rxCanResend = false.obs;
  final rxIsResending = false.obs;

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
    rxCountdownSeconds.value = 60;
    rxCanResend.value = false;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (rxCountdownSeconds.value == 0) {
          timer.cancel();
          rxCanResend.value = true;
        } else {
          rxCountdownSeconds.value--;
        }
      },
    );
  }

  void resendEmail() async {
    if (rxIsResending.value) return;

    rxIsResending.value = true;

    try {
      bool isSuccess = await LoginHelper().signInWithEmailAndLink(
        email,
        Get.find<EnvironmentService>().config.authlink,
      );
      if (isSuccess) {
        Fluttertoast.showToast(
          msg: 'resendEmailSuccessToast'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
        // Restart timer after successful resend
        startTimer();
      } else {
        Fluttertoast.showToast(
          msg: 'resendEmailFailedToast'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error resending email: $e');
      Fluttertoast.showToast(
        msg: 'resendEmailErrorToast'.tr + e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    } finally {
      rxIsResending.value = false;
    }
  }
}
