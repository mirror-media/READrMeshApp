import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/dataConstants.dart';

void showMeshToast({
  required Widget icon,
  required String message,
}) async {
  showToastWidget(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Get.isDarkMode ? meshBlack87 : meshBlack66,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(
            width: 6.0,
          ),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
    context: Get.overlayContext,
    animation: StyledToastAnimation.slideFromTop,
    reverseAnimation: StyledToastAnimation.slideToTop,
    position: StyledToastPosition.top,
    startOffset: const Offset(0.0, -3.0),
    reverseEndOffset: const Offset(0.0, -3.0),
    duration: const Duration(seconds: 3),
    animDuration: const Duration(milliseconds: 250),
    curve: Curves.linear,
    reverseCurve: Curves.linear,
  );
}

void showFollowingSyncToast() {
  final prefs = Get.find<SharedPreferencesService>().prefs;
  showMeshToast(
    icon: const Icon(
      Icons.check_circle,
      size: 16,
      color: Colors.white,
    ),
    message: 'syncFollowingPublisherToast'.tr,
  );
  prefs.setStringList('followingPublisherIds', []);
}
