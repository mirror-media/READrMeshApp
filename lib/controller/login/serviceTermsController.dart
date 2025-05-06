import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';

class ServiceTermsController extends GetxController {
  final String email = Get.arguments['email'];
  final rxAgreed = false.obs;
  final rxIsSending = false.obs;
  final rxIsLoading = true.obs;
  final rxCanAgree = false.obs;
  final rxnTermsContent = RxnString();
  final rxnError = RxnString();

  final ScrollController scrollController = ScrollController();

  final String termsUrl =
      Get.find<EnvironmentService>().config.termsOfServiceUrl;
  final String policyUrl =
      Get.find<EnvironmentService>().config.privacyPolicyUrl;

  @override
  void onInit() {
    super.onInit();
    _fetchTermsContent();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (!rxCanAgree.value &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 10) {
      rxCanAgree.value = true;
    }
  }

  Future<void> _fetchTermsContent() async {
    rxIsLoading.value = true;
    rxnError.value = null;

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(termsUrl)),
        http.get(Uri.parse(policyUrl)),
      ]);

      final termsResponse = responses[0];
      final policyResponse = responses[1];

      if (termsResponse.statusCode == 200 && policyResponse.statusCode == 200) {
        String decodedTermsHtml = utf8.decode(termsResponse.bodyBytes);
        const termsStartMarker = '精鏡傳媒股份有限公司';
        int termsStartIndex = decodedTermsHtml.indexOf(termsStartMarker);
        String processedTermsContent;
        if (termsStartIndex != -1) {
          processedTermsContent =
              '<h2>服務條款</h2>\n\n${decodedTermsHtml.substring(termsStartIndex)}';
        } else {
          print('Warning: Terms start marker not found.');
          processedTermsContent = '<h2>服務條款</h2>\n\n$decodedTermsHtml';
        }

        String decodedPolicyHtml = utf8.decode(policyResponse.bodyBytes);
        const policyStartMarker = '歡迎您光臨';
        int policyStartIndex = decodedPolicyHtml.indexOf(policyStartMarker);
        String processedPolicyContent;
        if (policyStartIndex != -1) {
          processedPolicyContent =
              '<h2>隱私權政策</h2>\n\n${decodedPolicyHtml.substring(policyStartIndex)}';
        } else {
          print('Warning: Policy start marker not found.');
          processedPolicyContent = '<h2>隱私權政策</h2>\n\n$decodedPolicyHtml';
        }

        rxnTermsContent.value =
            '$processedTermsContent\n\n<hr style="height:1px;border-width:0;color:gray;background-color:gray">\n\n$processedPolicyContent';
      } else {
        throw Exception(
            'Failed to load content - Terms: ${termsResponse.statusCode}, Policy: ${policyResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching terms/policy: $e');
      rxnError.value = '無法載入服務條款，請稍後再試。';
    } finally {
      rxIsLoading.value = false;
    }
  }

  void toggleAgreed() {
    if (rxCanAgree.value) {
      rxAgreed.toggle();
    }
  }

  Future<void> handleNextStep() async {
    if (rxIsSending.value || !rxAgreed.value) {
      return;
    }
    rxIsSending.value = true;
    try {
      bool isSuccess = await LoginHelper().signInWithEmailAndLink(
        email,
        Get.find<EnvironmentService>().config.authlink,
      );
      if (isSuccess) {
        Get.off(() => SentEmailPage(email));
      } else {
        Fluttertoast.showToast(
          msg: "emailDeliveryFailed".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
        rxIsSending.value = false;
      }
    } catch (e) {
      print('Error in handleNextStep: $e');
      Fluttertoast.showToast(
        msg: "Error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      rxIsSending.value = false;
    }
  }
}
