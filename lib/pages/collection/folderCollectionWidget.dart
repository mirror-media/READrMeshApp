import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';

class FolderCollectionWidget extends GetView<CollectionPageController> {
  final Collection collection;
  const FolderCollectionWidget(this.collection);

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionPageController>(
      tag: collection.id,
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchCollectionData(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Expanded(
                    child: _buildContent(),
                  ),
                  SizedBox(
                    height: Get.height * 0.13,
                  ),
                ],
              ),
              BottomCardWidget(
                controllerTag: collection.controllerTag,
                title: controller.collection.title,
                author: collection.creator,
                id: collection.id,
                objective: PickObjective.collection,
                allComments: controller.allComments,
                popularComments: controller.popularComments,
              ),
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildContent() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _collectionInfo();
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child:
                NewsListItemWidget(controller.collectionPicks[index - 1].news!),
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0) {
            return const Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            );
          }

          return const Divider(
            color: readrBlack10,
            thickness: 1,
            height: 1,
            indent: 20,
            endIndent: 20,
          );
        },
        itemCount: controller.collectionPicks.length + 1,
      ),
    );
  }

  Widget _collectionInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => CachedNetworkImage(
            imageUrl:
                Get.find<PickableItemController>(tag: collection.controllerTag)
                        .collectionHeroImageUrl
                        .value ??
                    collection.ogImageUrl,
            width: Get.width,
            height: Get.width / 2,
            placeholder: (context, url) => Container(
              height: Get.width / 2,
              width: Get.width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(),
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: GestureDetector(
            onTap: () =>
                Get.to(() => PersonalFilePage(viewMember: collection.creator)),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: readrBlack50,
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: readrBlack87,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Obx(
            () => GestureDetector(
              onTap: () {
                if (controller.expandDescription.isFalse) {
                  controller.expandDescription.value = true;
                }
              },
              child: ExtendedText(
                controller.collectionDescription.value,
                maxLines: controller.expandDescription.value ? null : 3,
                style: const TextStyle(
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                joinZeroWidthSpace: true,
                overflowWidget: TextOverflowWidget(
                  position: TextOverflowPosition.end,
                  child: RichText(
                    text: const TextSpan(
                      text: '.... ',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 9, 40, 0.66),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: '展開更多',
                          style: TextStyle(
                            color: readrBlack50,
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Obx(
                () => ExtendedText(
                  '${controller.collectionPicks.length}篇文章',
                  joinZeroWidthSpace: true,
                  style: const TextStyle(
                    fontSize: 13,
                    color: readrBlack50,
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: readrBlack20,
                ),
              ),
              Timestamp(
                collection.publishedTime,
                textSize: 13,
                key: Key(collection.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
