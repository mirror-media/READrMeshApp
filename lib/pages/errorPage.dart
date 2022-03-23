import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';

class ErrorPage extends StatelessWidget {
  final dynamic error;
  final void Function() onPressed;
  final bool needPop;
  final bool hideAppbar;
  const ErrorPage({
    required this.error,
    required this.onPressed,
    this.needPop = false,
    this.hideAppbar = true,
  });
  @override
  Widget build(BuildContext context) {
    String title = '500';
    String description = '看來有哪裡出錯了...';
    String imagePath = error500Svg;
    if (error is Error400Exception) {
      title = '404';
      description = '找不到這頁的資料...';
      imagePath = error400Svg;
    } else if (error is NoInternetException) {
      title = '沒有網際網路連線';
      description = '請確認您已連接網路';
      imagePath = noInternetSvg;
    }
    void Function() onPressedFunction = onPressed;
    if (needPop) {
      onPressedFunction = () {
        onPressed;
        context.popRoute();
      };
    }

    if (hideAppbar) {
      return _errorWidget(
        title: title,
        description: description,
        imagePath: imagePath,
        onPressedFunction: onPressedFunction,
      );
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: const Text(
          'Logo',
          style: TextStyle(
            color: readrBlack,
            fontSize: 18,
          ),
        ),
      ),
      body: _errorWidget(
        title: title,
        description: description,
        imagePath: imagePath,
        onPressedFunction: onPressedFunction,
      ),
    );
  }

  Widget _errorWidget({
    required String title,
    required String description,
    required String imagePath,
    required void Function() onPressedFunction,
  }) {
    return Container(
      color: const Color.fromRGBO(246, 246, 251, 1),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 120,
          ),
          SvgPicture.asset(
            imagePath,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: const TextStyle(
              color: readrBlack87,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            description,
            style: const TextStyle(
              color: Color.fromRGBO(0, 9, 40, 0.66),
              decoration: TextDecoration.none,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 48,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 135),
            child: OutlinedButton(
              child: const Text(
                '重新嘗試',
                style: TextStyle(
                  color: readrBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                side: const BorderSide(color: readrBlack30),
              ),
              onPressed: onPressedFunction,
            ),
          ),
        ],
      ),
    );
  }
}
