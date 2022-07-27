import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/sortStoryPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionStoryItem.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/services/collectionService.dart';

class SortStoryPage extends GetView<SortStoryPageController> {
  final bool isEdit;
  final List<CollectionStory> originalList;
  final Collection? collection;
  const SortStoryPage(
    this.originalList, {
    this.isEdit = false,
    this.collection,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(SortStoryPageController(
      CollectionService(),
      originalList,
      isEdit,
      collection: collection,
    ));
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasChange) {
          return await _showLeaveAlertDialog(context) ?? false;
        } else {
          return true;
        }
      },
      child: Obx(
        () {
          if (controller.isUpdating.isTrue) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitWanderingCubes(
                    color: readrBlack,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      isEdit ? '更新集錦中' : '集錦建立中',
                      style: const TextStyle(
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
              leading: isEdit
                  ? TextButton(
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: readrBlack50,
                        ),
                      ),
                      onPressed: () async {
                        if (controller.hasChange) {
                          await _showLeaveAlertDialog(context);
                        } else {
                          Get.back();
                        }
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: readrBlack87,
                      ),
                      onPressed: () async {
                        if (controller.hasChange) {
                          await _showLeaveAlertDialog(context);
                        } else {
                          Get.back();
                        }
                      },
                    ),
              title: Text(
                isEdit ? '編輯排序' : '排序',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: readrBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                TextButton(
                  child: Text(
                    isEdit ? '儲存' : '建立',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () async {
                    if (isEdit) {
                      controller.updateCollectionPicks();
                    } else {
                      controller.createCollection();
                    }
                  },
                ),
              ],
            ),
            body: Obx(
              () => ReorderableListView.builder(
                itemBuilder: (context, index) => Dismissible(
                  key: Key(controller.collectionStoryList[index].news.id),
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
                    controller.collectionStoryList.removeAt(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      title: CollectionStoryItem(
                          controller.collectionStoryList[index]),
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
                itemCount: controller.collectionStoryList.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item =
                      controller.collectionStoryList.removeAt(oldIndex);
                  controller.collectionStoryList.insert(newIndex, item);
                },
              ),
            ),
            floatingActionButton: isEdit
                ? FloatingActionButton(
                    backgroundColor: readrBlack,
                    foregroundColor: Colors.white,
                    onPressed: () async {
                      List<CollectionStory> newCollectionStory =
                          await Get.to(() => ChooseStoryPage(
                                    isEdit: isEdit,
                                    pickedStoryIds: List<String>.from(
                                      controller.collectionStoryList.map(
                                        (element) => element.news.id,
                                      ),
                                    ),
                                  )) ??
                              [];
                      controller.collectionStoryList
                          .insertAll(0, newCollectionStory);
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }

  Future<bool?> _showLeaveAlertDialog(BuildContext context) async {
    return await showPlatformDialog<bool>(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text(
          '捨棄變更？',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '如果現在返回，將不會儲存變更。',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Get.back(),
            child: PlatformText(
              '繼續編輯',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.blue,
              ),
            ),
          ),
          PlatformDialogAction(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: PlatformText(
              '捨棄變更',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
