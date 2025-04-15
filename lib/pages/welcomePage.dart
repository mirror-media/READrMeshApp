import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/loginPage.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<Widget> _widgets = [];

  @override
  Widget build(BuildContext context) {
    _widgets = [
      _onboardItem(
        context: context,
        imagePath: onboard1Png,
        title: 'item1Title'.tr,
        description: 'item1Description'.tr,
        widthPadding: 80,
      ),
      _onboardItem(
        context: context,
        imagePath: onboard2Png,
        title: 'item2Title'.tr,
        description: 'item2Description'.tr,
        widthPadding: 40,
      ),
      _onboardItem(
        context: context,
        imagePath: onboard3Png,
        title: 'item3Title'.tr,
        description: 'item3Description'.tr,
        widthPadding: 40,
      ),
      _onboardItem(
        context: context,
        imagePath: onboard4Png,
        title: 'item4Title'.tr,
        description: 'item4Description'.tr,
        widthPadding: 40,
      ),
    ];
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CarouselSlider(
                  items: _widgets,
                  carouselController: _controller,
                  options: CarouselOptions(
                      height: context.height - 172.5,
                      autoPlay: true,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _widgets.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == entry.key
                              ? Theme.of(context)
                                  .extension<CustomColors>()!
                                  .primary700!
                              : Theme.of(context)
                                  .extension<CustomColors>()!
                                  .primary200!,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Divider(
                height: 0.5,
                thickness: 0.5,
              ),
              Container(
                width: double.infinity,
                height: 80,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: ElevatedButton(
                  onPressed: () =>
                      Get.off(() => const LoginPage(fromOnboard: true)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).extension<CustomColors>()?.primary700,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'startToUse'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        }
        return false;
      },
    );
  }

  Widget _onboardItem({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required double widthPadding,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Image.asset(
            imagePath,
            width: context.width - widthPadding * 2,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()?.primary500,
          ),
        ),
      ],
    );
  }
}
