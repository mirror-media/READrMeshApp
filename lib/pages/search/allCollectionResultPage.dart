import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/searchPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/shared/collection/smallCollectionItem.dart';

class AllCollectionResultPage extends GetView<SearchPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'contain'.tr,
              style: const TextStyle(
                color: readrBlack,
                fontSize: 18,
              ),
            ),
            Text(
              controller.keyWord,
              style: const TextStyle(
                color: readrBlack,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'containsCollection'.tr,
              style: const TextStyle(
                color: readrBlack,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(
        () => GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: (context.width - 40 - 12) / 530,
          ),
          itemBuilder: (context, index) {
            if (index == controller.collectionResultList.length - 1 &&
                !controller.isLoadingMoreCollection &&
                !controller.noMoreCollection) {
              controller.loadMoreCollection();
              print('load more collection');
            }
            return SmallCollectionItem(
              controller.collectionResultList[index],
            );
          },
          itemCount: controller.collectionResultList.length,
        ),
      ),
    );
  }
}
