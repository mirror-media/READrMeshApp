import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/folderCollectionWidget.dart';
import 'package:readr/services/collectionPageService.dart';

class CollectionPage extends GetView<CollectionPageController> {
  final Collection collection;
  const CollectionPage(this.collection);

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
        ),
        tag: collection.id,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (collection.format) {
      case CollectionFormat.folder:
        return FolderCollectionWidget(collection);
      case CollectionFormat.timeline:
        return Container();
    }
  }
}