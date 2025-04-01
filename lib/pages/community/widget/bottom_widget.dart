import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BottomWidget extends StatelessWidget {
  final RxBool isMember;
  final RxBool isNoMore;
  final Function(double) onVisibilityChanged;

  const BottomWidget({
    super.key,
    required this.isMember,
    required this.isNoMore,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isMember.value) {
        return Container();
      }

      if (isNoMore.value) {
        return Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: RichText(
            text: TextSpan(
              text: '🎉 ',
              style: const TextStyle(
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'communityNoMore'.tr,
                  style: Theme.of(context).textTheme.labelMedium,
                )
              ],
            ),
          ),
        );
      } else {
        return VisibilityDetector(
          key: const Key('communityBottomWidget'),
          onVisibilityChanged: (visibilityInfo) {
            onVisibilityChanged(visibilityInfo.visibleFraction * 100);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        );
      }
    });
  }
}
