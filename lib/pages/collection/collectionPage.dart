import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
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

    Get.find<PubsubService>().logReadCollection(
      memberId: Get.find<UserService>().currentUser.memberId,
      collectionId: collection.id,
    );

    return GetBuilder<CollectionPageController>(
      tag: collection.id,
      builder: (controller) {
        if (controller.isError) {
          return Scaffold(
            appBar: _buildBar(context),
            body: ErrorPage(
              error: controller.error,
              onPressed: () => controller.fetchCollectionData(),
              hideAppbar: true,
            ),
          );
        }

        if (!controller.isLoading) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    CollectionAppBar(collection),
                    Expanded(
                      child: _buildBody(context),
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
          appBar: _buildBar(context),
          body: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      centerTitle: GetPlatform.isIOS,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'collection'.tr,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(
      () {
        if (controller.collectionPicks.isEmpty) {
          return CollectionEmptyWidget(collection);
        }

        Widget listWidget;
        Color background;
        switch (controller.collectionFormat.value) {
          case CollectionFormat.folder:
            listWidget = FolderCollectionWidget(collection);
            background = Theme.of(context).backgroundColor;
            break;
          case CollectionFormat.timeline:
            listWidget = TimelineCollectionWidget(collection);
            background = Colors.transparent;
            break;
        }

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              CollectionHeader(collection),
              if (controller.collectionFormat.value == CollectionFormat.folder)
                const Divider(
                  thickness: 1,
                  height: 1,
                ),
              listWidget,
            ],
          ),
        );
      },
    );
  }
}
