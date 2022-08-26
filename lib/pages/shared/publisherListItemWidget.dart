import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/followableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/shared/follow/followButton.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';

class PublisherListItemWidget extends GetView<FollowableItemController> {
  final Publisher publisher;
  const PublisherListItemWidget({required this.publisher});

  @override
  String get tag => 'publisher${publisher.id}';

  @override
  Widget build(BuildContext context) {
    PublisherFollowableItem item = PublisherFollowableItem(publisher);
    if (!Get.isRegistered<FollowableItemController>(tag: tag)) {
      Get.put<FollowableItemController>(
        FollowableItemController(item),
        tag: tag,
      );
    }
    bool originFollow = Get.find<UserService>().isFollowingPublisher(publisher);
    return Row(
      children: [
        PublisherLogoWidget(publisher),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publisher.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color: readrBlack87,
                ),
              ),
              Obx(
                () {
                  int followCount = publisher.followerCount;
                  if (originFollow && controller.isFollowed.isFalse) {
                    followCount--;
                  } else if (!originFollow && controller.isFollowed.isTrue) {
                    followCount++;
                  }

                  String s = '';
                  if (followCount > 1 && Get.locale?.languageCode == 'en') {
                    s = 's';
                  }

                  return Text(
                    '${followCount.toString()} ${'followerConunt'.tr}$s',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: readrBlack50,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        FollowButton(
          item,
        ),
      ],
    );
  }
}
