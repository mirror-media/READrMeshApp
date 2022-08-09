import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/shared/collectionAppBar.dart';
import 'package:readr/pages/collection/folderCollectionWidget.dart';
import 'package:readr/pages/collection/shared/collectionEmptyWidget.dart';
import 'package:readr/pages/collection/shared/collectionHeader.dart';
import 'package:readr/pages/collection/timelineCollectionWidget.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/services/collectionPageService.dart';
import 'package:readr/services/collectionService.dart';

class CollectionPage extends GetView<CollectionPageController> {
  final Collection collection;
  final bool isNewCollection;
  const CollectionPage(this.collection, {this.isNewCollection = false});

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<CollectionPageController>(tag: collection.id)) {
      Get.find<CollectionPageController>(tag: collection.id)
          .fetchCollectionData();
    } else {
      Get.put(
        CollectionPageController(
          collection: collection,
          collectionPageRepos: CollectionPageService(),
          collectionRepos: CollectionService(),
          isNewCollection: isNewCollection,
        ),
        tag: collection.id,
      );
    }

    logViewCollection(collection);

    return GetBuilder<CollectionPageController>(
      tag: collection.id,
      builder: (controller) {
        if (controller.isError) {
          return Scaffold(
            appBar: _buildBar(),
            body: ErrorPage(
              error: controller.error,
              onPressed: () => controller.fetchCollectionData(),
              hideAppbar: true,
            ),
          );
        }

        if (!controller.isLoading) {
          return Scaffold(
            appBar: CollectionAppBar(collection),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildBody(),
                    ),
                    SizedBox(
                      height: context.height * 0.12,
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
            ),
          );
        }

        return Scaffold(
          appBar: _buildBar(),
          body: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      centerTitle: GetPlatform.isIOS,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '集錦',
        style: TextStyle(
          fontSize: 18,
          color: readrBlack,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(
      () {
        if (controller.collectionPicks.isEmpty) {
          return CollectionEmptyWidget(collection);
        }

        Widget listWidget;
        switch (controller.collectionFormat.value) {
          case CollectionFormat.folder:
            listWidget = FolderCollectionWidget(collection);
            break;
          case CollectionFormat.timeline:
            listWidget = TimelineCollectionWidget(collection);
            break;
        }

        return ListView(
          padding: const EdgeInsets.all(0),
          children: [
            CollectionHeader(collection),
            if (controller.collectionFormat.value == CollectionFormat.folder)
              const Divider(
                color: readrBlack10,
                thickness: 1,
                height: 1,
              ),
            listWidget,
          ],
        );
      },
    );
  }
}
