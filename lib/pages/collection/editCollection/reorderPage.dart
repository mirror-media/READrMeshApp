import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/editCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/collectionStoryItem.dart';
import 'package:readr/pages/collection/editCollection/addStoryPage.dart';
import 'package:readr/services/collectionService.dart';

class ReorderPage extends GetView<EditCollectionController> {
  final Collection collection;
  const ReorderPage({required this.collection});

  @override
  Widget build(BuildContext context) {
    Get.put(EditCollectionController(
      collection: collection,
      collectionRepos: CollectionService(),
      isReorderPage: true,
    ));
    return Obx(
      () {
        if (controller.isUpdating.isTrue) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    '更新集錦中',
                    style: TextStyle(
                      fontSize: 20,
                      color: readrBlack,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0.5,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            centerTitle: GetPlatform.isIOS,
            leading: TextButton(
              child: const Text(
                '取消',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: readrBlack50,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              '編輯排序',
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
                  '儲存',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  controller.updateCollectionPicks();
                },
              ),
            ],
          ),
          body: Obx(
            () => ReorderableListView.builder(
              itemBuilder: (context, index) => Dismissible(
                key: Key(controller.newList[index].news!.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  color: Colors.red,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                onDismissed: (direction) {
                  controller.newList.removeAt(index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    title: CollectionStoryItem(controller.newList[index]),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    minLeadingWidth: 20,
                    leading: const Icon(
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
              ),
              itemCount: controller.newList.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = controller.newList.removeAt(oldIndex);
                controller.newList.insert(newIndex, item);
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: readrBlack,
            foregroundColor: Colors.white,
            onPressed: () => Get.to(() => AddStoryPage()),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
