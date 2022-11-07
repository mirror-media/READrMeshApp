import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/collection/collectionTimestamp.dart';

class CollectionHeader extends GetView<CollectionPageController> {
  final Collection collection;
  const CollectionHeader(this.collection);

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => CachedNetworkImage(
              imageUrl: Get.find<PickableItemController>(
                          tag: collection.controllerTag)
                      .collectionHeroImageUrl
                      .value ??
                  collection.ogImageUrl,
              width: context.width,
              height: context.width / 2,
              placeholder: (context, url) => Container(
                height: context.width / 2,
                width: context.width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: GestureDetector(
              onTap: () => Get.to(
                  () => PersonalFilePage(viewMember: collection.creator)),
              child: Obx(() {
                String authorCustomId = collection.creator.customId;
                if (Get.find<UserService>().isMember.isTrue &&
                    Get.find<UserService>().currentUser.memberId ==
                        collection.creator.memberId) {
                  authorCustomId = Get.find<UserService>().currentUser.customId;
                }
                return ExtendedText(
                  '@$authorCustomId',
                  joinZeroWidthSpace: true,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary500,
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Obx(
              () => ExtendedText(
                Get.find<PickableItemController>(tag: collection.controllerTag)
                        .collectionTitle
                        .value ??
                    collection.title,
                joinZeroWidthSpace: true,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Obx(() {
            if (controller.collectionDescription.isEmpty) {
              return Container();
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: GestureDetector(
                onTap: () {
                  if (controller.expandDescription.isFalse) {
                    controller.expandDescription.value = true;
                  }
                },
                child: Obx(
                  () => ExtendedText(
                    controller.collectionDescription.value,
                    maxLines: controller.expandDescription.value ? null : 3,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary600,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    joinZeroWidthSpace: true,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.end,
                      child: RichText(
                        text: TextSpan(
                          text: '.... ',
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primary600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: 'expandDescription'.tr,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .extension<CustomColors>()
                                    ?.primary500,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Obx(
                  () => ExtendedText.rich(
                    TextSpan(
                      text:
                          '${controller.collectionPicks.length}${'articleCount'.tr}',
                      children: [
                        if (controller.collectionPicks.length > 1 &&
                            Get.locale?.languageCode == 'en')
                          const TextSpan(text: 's'),
                      ],
                    ),
                    joinZeroWidthSpace: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary500,
                    ),
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      leading: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 0.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primaryLv5,
                  ),
                ),
                Obx(
                  () => CollectionTimestamp(
                    Get.find<PickableItemController>(
                            tag: collection.controllerTag)
                        .collectionUpdatetime
                        .value,
                    textSize: 13,
                    key: UniqueKey(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
