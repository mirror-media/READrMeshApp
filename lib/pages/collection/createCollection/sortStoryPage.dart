import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/collection/createCollection/collectionStoryItem.dart';

class SortStoryPage extends GetView<CreateCollectionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '排序',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: readrBlack,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            child: const Text(
              '建立',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(
        () => ReorderableListView.builder(
          itemBuilder: (context, index) => Padding(
            key: Key(controller.selectedList[index].id),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              title: CollectionStoryItem(controller.selectedList[index]),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              trailing: const Icon(
                Icons.reorder_outlined,
                color: readrBlack30,
              ),
              shape: BorderDirectional(
                top: index == 0
                    ? BorderSide.none
                    : const BorderSide(color: readrBlack10, width: 1),
              ),
            ),
          ),
          itemCount: controller.selectedList.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = controller.selectedList.removeAt(oldIndex);
            controller.selectedList.insert(newIndex, item);
          },
        ),
      ),
    );
  }
}
