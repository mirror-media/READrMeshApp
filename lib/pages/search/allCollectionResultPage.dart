import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/searchPageController.dart';
import 'package:readr/pages/shared/collection/smallCollectionItem.dart';

class AllCollectionResultPage extends GetView<SearchPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'contain'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
            Text(
              controller.keyWord,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'containsCollection'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
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
