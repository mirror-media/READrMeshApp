import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:shimmer/shimmer.dart';

class PickCollectionItem extends StatelessWidget {
  final Collection collection;
  const PickCollectionItem(this.collection);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => CollectionPage(collection)),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                      width: 150,
                      height: 75,
                      placeholder: (context, url) => SizedBox(
                        height: 75,
                        width: 150,
                        child: Shimmer.fromColors(
                          baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                          highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                          child: Container(
                            height: 75,
                            width: 150,
                            color: Colors.white,
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
              const Spacer(),
              Padding(
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: readrBlack50,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 2),
              const Spacer(),
              Padding(
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: readrBlack87,
                      fontWeight: FontWeight.w500,
                    ),
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
                      return const Text(
                        '尚無人精選',
                        style: TextStyle(fontSize: 13, color: readrBlack50),
                      );
                    }
                    return RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: pickCountData.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: readrBlack,
                          fontWeight: FontWeight.w500,
                        ),
                        children: const [
                          TextSpan(
                            text: ' 人精選',
                            style: TextStyle(
                              fontSize: 13,
                              color: readrBlack50,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PickButton(
                  collection.controllerTag,
                  expanded: true,
                  textSize: 16,
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
