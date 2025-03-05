import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/pages/community/community_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BottomWidget extends StatelessWidget {
  final CommunityController controller;

  const BottomWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isNoMore = controller.isNoMore.value;
        final isLoadingMore = controller.isLoadingMore.value;

        if (!controller.isMember) {
          return Container();
        }
        if (isNoMore) {
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
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && !isLoadingMore) {
                controller.fetchMoreFollowingPickedNews();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }
      },
    );
  }
}
