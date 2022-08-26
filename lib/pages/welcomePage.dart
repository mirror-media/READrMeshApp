import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/invitationCode/inputInvitationCodePage.dart';

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
        svgPath: onboard1Svg,
        title: 'item1Title'.tr,
        description: 'item1Description'.tr,
        widthPadding: 80,
      ),
      _onboardItem(
        context: context,
        svgPath: onboard2Svg,
        title: 'item2Title'.tr,
        description: 'item2Description'.tr,
        widthPadding: 40,
      ),
      _onboardItem(
        context: context,
        svgPath: onboard3Svg,
        title: 'item3Title'.tr,
        description: 'item3Description'.tr,
        widthPadding: 40,
      ),
      _onboardItem(
        context: context,
        svgPath: onboard4Svg,
        title: 'item4Title'.tr,
        description: 'item4Description'.tr,
        widthPadding: 40,
      ),
    ];
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.white,
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
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : readrBlack)
                                    .withOpacity(
                                        _current == entry.key ? 0.87 : 0.1)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Divider(
                color: readrBlack10,
                height: 0.5,
                thickness: 0.5,
              ),
              Container(
                width: double.infinity,
                height: 80,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: ElevatedButton(
                  onPressed: () =>
                      Get.off(() => const InputInvitationCodePage()),
                  style: ElevatedButton.styleFrom(
                    primary: readrBlack87,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'startToUse'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
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
    required String svgPath,
    required String title,
    required String description,
    required double widthPadding,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: SvgPicture.asset(
            svgPath,
            width: context.width - widthPadding * 2,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: readrBlack87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: readrBlack50,
          ),
        ),
      ],
    );
  }
}
