import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';

void showFollowingSyncToast() {
  final prefs = Get.find<SharedPreferencesService>().prefs;
  showToastWidget(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color.fromRGBO(0, 9, 40, 0.66),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(
            width: 6.0,
          ),
          Text(
            '已同步追蹤名單',
            style: TextStyle(
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
    //Animation duration   animDuration * 2 <= duration
    animDuration: const Duration(milliseconds: 250),
    curve: Curves.linear,
    reverseCurve: Curves.linear,
  );
  prefs.setStringList('followingPublisherIds', []);
}