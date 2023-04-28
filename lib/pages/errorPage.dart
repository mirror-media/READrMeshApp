import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/helpers/themes.dart';

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
        context: context,
        title: title,
        description: description,
        imagePath: imagePath,
        onPressedFunction: onPressedFunction,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_outlined,
              color: Theme.of(context).appBarTheme.foregroundColor,
              size: 26,
            ),
            tooltip: 'back'.tr,
          ),
        ],
      ),
      body: _errorWidget(
        context: context,
        title: title,
        description: description,
        imagePath: imagePath,
        onPressedFunction: onPressedFunction,
      ),
    );
  }

  Widget _errorWidget({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required void Function() onPressedFunction,
  }) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.displaySmall,
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
                side: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary700!),
              ),
              onPressed: onPressedFunction,
              child: Text(
                'retry'.tr,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
