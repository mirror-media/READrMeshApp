import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class PickToast {
  static void showPickToast(
      BuildContext context, bool isSuccess, bool isCreate) {
    String message;
    if (isCreate) {
      message = isSuccess ? '成功加入精選' : '加入精選失敗';
    } else {
      message = isSuccess ? '成功移除精選' : '移除精選失敗';
    }
    IconData iconData = isSuccess ? Icons.check_circle : Icons.error;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color.fromRGBO(0, 9, 40, 0.66),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: Colors.white,
          ),
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
    );
    showToastWidget(
      toast,
      context: context,
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
  }
}
