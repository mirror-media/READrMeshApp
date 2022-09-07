import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
    String description = '500Description'.tr;
    String imagePath = error500Svg;
    if (error is Error400Exception) {
      title = '404';
      description = '404Description'.tr;
      imagePath = error400Svg;
    } else if (error is NoInternetException) {
      title = 'noInternetTitle'.tr;
      description = 'noInternetDescription'.tr;
      imagePath = noInternetSvg;
    }
    void Function() onPressedFunction = onPressed;
    if (needPop) {
      onPressedFunction = () {
        onPressed;
        Get.back();
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
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_outlined,
              color: readrBlack87,
              size: 26,
            ),
            tooltip: 'back'.tr,
          ),
        ],
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
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                side: const BorderSide(color: readrBlack30),
              ),
              onPressed: onPressedFunction,
              child: Text(
                'retry'.tr,
                style: const TextStyle(
                  color: readrBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
