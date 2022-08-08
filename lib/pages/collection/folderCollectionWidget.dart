import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/shared/collectionHeader.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/shared/collection/collectionTimestamp.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';

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
            return CollectionHeader(collection);
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child:
                NewsListItemWidget(controller.collectionPicks[index - 1].news),
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
}
