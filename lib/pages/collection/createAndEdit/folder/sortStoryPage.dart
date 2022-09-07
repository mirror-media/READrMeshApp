import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/collection/createAndEdit/sortStoryPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/chooseFormatPage.dart';
import 'package:readr/pages/collection/createAndEdit/collectionStoryItem.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/services/collectionService.dart';

class SortStoryPage extends GetView<SortStoryPageController> {
  final bool isEdit;
  final bool isChangeFormat;
  final List<FolderCollectionPick> originalList;
  final Collection? collection;
  final bool isAddToEmpty;
  const SortStoryPage(
    this.originalList, {
    this.isEdit = false,
    this.collection,
    this.isChangeFormat = false,
    this.isAddToEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(SortStoryPageController(
      CollectionService(),
      originalList,
      isEdit,
      collection: collection,
    ));
    if (isChangeFormat || isAddToEmpty) {
      controller.hasChange.value = true;
    }
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasChange.isTrue) {
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
                      (isEdit || isChangeFormat || isAddToEmpty)
                          ? 'updatingCollection'.tr
                          : 'creatingCollection'.tr,
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
              leading: (isEdit || isChangeFormat || isAddToEmpty)
                  ? TextButton(
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: readrBlack50,
                        ),
                      ),
                      onPressed: () async {
                        if (controller.hasChange.isTrue ||
                            isChangeFormat ||
                            isAddToEmpty) {
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
                      onPressed: () => Get.back(),
                    ),
              leadingWidth: 75,
              title: Text(
                isEdit ? 'editSort'.tr : 'sort'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: readrBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                Obx(
                  () {
                    if (controller.hasChange.isFalse && isEdit) {
                      return Container();
                    }
                    return TextButton(
                      child: Text(
                        (isEdit || isChangeFormat || isAddToEmpty)
                            ? 'save'.tr
                            : 'create'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        if (isEdit || isAddToEmpty || isChangeFormat) {
                          controller.updateCollectionPicks();
                        } else {
                          controller.createCollection();
                        }
                      },
                    );
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
                          controller.collectionStoryList[index].news),
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
            floatingActionButton: (isEdit || isChangeFormat || isAddToEmpty)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: JustTheTooltip(
                          content: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Text(
                              'changeCollectionType'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          backgroundColor: const Color(0xFF007AFF),
                          preferredDirection: AxisDirection.up,
                          margin: const EdgeInsets.only(left: 20),
                          tailLength: 8,
                          tailBaseWidth: 12,
                          tailBuilder: (tip, point2, point3) => Path()
                            ..moveTo(tip.dx, tip.dy)
                            ..lineTo(point2.dx, point2.dy)
                            ..lineTo(point3.dx, point3.dy)
                            ..close(),
                          controller: controller.tooltipController,
                          shadow: const Shadow(
                              color: Color.fromRGBO(0, 122, 255, 0.2)),
                          child: ElevatedButton(
                            onPressed: () => Get.to(
                              () => ChooseFormatPage(
                                controller.collectionStoryList,
                                isEdit: true,
                                collection: collection,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff04295E),
                              shadowColor: readrBlack30,
                              padding: const EdgeInsets.all(12),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              elevation: 6,
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_right_arrow_left,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          List<CollectionPick> newCollectionPicks =
                              await Get.to(() => ChooseStoryPage(
                                        isEdit: isEdit ||
                                            isChangeFormat ||
                                            isAddToEmpty,
                                        pickedStoryIds: List<String>.from(
                                          controller.collectionStoryList.map(
                                            (element) => element.news.id,
                                          ),
                                        ),
                                      )) ??
                                  [];
                          List<FolderCollectionPick> newFolderCollectionList =
                              List<FolderCollectionPick>.from(
                                  newCollectionPicks.map((e) =>
                                      FolderCollectionPick.fromCollectionPick(
                                          e)));
                          controller.collectionStoryList
                              .insertAll(0, newFolderCollectionList);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: readrBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shadowColor: readrBlack30,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                          ),
                          elevation: 6,
                        ),
                        icon: const Icon(
                          CupertinoIcons.add,
                          size: 17,
                          color: Colors.white,
                        ),
                        label: Text(
                          'add'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
        title: Text(
          'editLeaveAlertTitle'.tr,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'editLeaveAlertContent'.tr,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Get.back(),
            child: PlatformText(
              'continueEditing'.tr,
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
              'discardChanges'.tr,
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
