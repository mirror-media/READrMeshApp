import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:shimmer/shimmer.dart';

class SmallCollectionItem extends StatelessWidget {
  final Collection collection;
  final bool showPickTooltip;
  const SmallCollectionItem(this.collection, {this.showPickTooltip = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => CollectionPage(collection)),
      child: Card(
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Obx(
                    () => CachedNetworkImage(
                      imageUrl: Get.find<PickableItemController>(
                                  tag: collection.controllerTag)
                              .collectionHeroImageUrl
                              .value ??
                          collection.ogImageUrl,
                      fit: BoxFit.cover,
                      width: context.width,
                      height: 75,
                      placeholder: (context, url) => SizedBox(
                        height: 75,
                        width: 150,
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .primaryLv6!
                              .withOpacity(0.15),
                          highlightColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .primaryLv6!,
                          child: Container(
                            height: 75,
                            width: 150,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 4),
                    child: CollectionTag(
                      smallTag: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 17,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => Get.to(
                      () => PersonalFilePage(viewMember: collection.creator)),
                  child: Obx(() {
                    String authorText = '@${collection.creator.customId}';
                    if (Get.find<UserService>().isMember.isTrue &&
                        collection.creator.memberId ==
                            Get.find<UserService>().currentUser.memberId) {
                      authorText =
                          '@${Get.find<UserService>().currentUser.customId}';
                    }
                    return ExtendedText(
                      authorText,
                      maxLines: 1,
                      joinZeroWidthSpace: true,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(
                  () => ExtendedText(
                    Get.find<PickableItemController>(
                                tag: collection.controllerTag)
                            .collectionTitle
                            .value ??
                        collection.title,
                    joinZeroWidthSpace: true,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 14),
                    maxLines: 2,
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(
                  () {
                    final controller = Get.find<PickableItemController>(
                        tag: collection.controllerTag);
                    int pickCountData = controller.pickCount.value;
                    if (pickCountData <= 0) {
                      return Text(
                        'noPick'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 13),
                      );
                    }
                    return RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: pickCountData.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'pickCount'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 13),
                          ),
                          if (pickCountData > 1 &&
                              Get.locale?.languageCode == 'en')
                            TextSpan(
                              text: 's',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 13),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PickButton(
                  collection.controllerTag,
                  expanded: true,
                  textSize: 16,
                  showPickTooltip: showPickTooltip,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
