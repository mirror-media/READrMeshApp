import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/getxServices/internetCheckService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/collection/collectionStoryItem.dart';

class SortStoryPage extends GetView<CreateCollectionController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isCreating.isTrue) {
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
                    '集錦建立中',
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
                onPressed: () async {
                  if (await Get.find<InternetCheckService>()
                      .meshCheckInstance
                      .hasConnection) {
                    controller.createCollection();
                  }
                },
              ),
            ],
          ),
          body: Obx(
            () => ReorderableListView.builder(
              itemBuilder: (context, index) => Padding(
                key: Key(controller.selectedList[index].news!.id),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  title: CollectionStoryItem(controller.selectedList[index]),
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
      },
    );
  }
}
