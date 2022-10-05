import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';

class FolderCollectionWidget extends GetView<CollectionPageController> {
  final Collection collection;
  const FolderCollectionWidget(this.collection);

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            NewsListItemWidget(controller.collectionPicks[index].newsListItem!),
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 36,
        ),
        itemCount: controller.collectionPicks.length,
      ),
    );
  }
}
