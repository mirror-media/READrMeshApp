import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/collection/createAndEdit/sortStoryPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
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
              backgroundColor: Theme.of(context).backgroundColor,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWanderingCubes(
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary700,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      (isEdit || isChangeFormat || isAddToEmpty)
                          ? 'updatingCollection'.tr
                          : 'creatingCollection'.tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontSize: 20),
                    ),
                  ),
                ],
              ),
            );
          }
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.5,
              centerTitle: GetPlatform.isIOS,
              leading: (isEdit || isChangeFormat || isAddToEmpty)
                  ? TextButton(
                      child: Text(
                        'cancel'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 18),
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
                      icon: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      onPressed: () => Get.back(),
                    ),
              leadingWidth: 75,
              title: Text(
                isEdit ? 'editSort'.tr : 'sort'.tr,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontSize: 18),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color:
                              Theme.of(context).extension<CustomColors>()?.blue,
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
                  key: Key(controller.collectionStoryList[index].news.id +
                      controller.collectionStoryList[index].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Theme.of(context).extension<CustomColors>()?.red,
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
                      leading: Icon(
                        Icons.reorder_outlined,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary400,
                      ),
                      shape: BorderDirectional(
                        top: index == 0
                            ? BorderSide.none
                            : BorderSide(
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .primaryLv6!,
                                width: 1),
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
                          backgroundColor:
                              Theme.of(context).extension<CustomColors>()?.blue,
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
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xff04295E)
                                  : const Color(0xffEBF02C),
                              shadowColor: meshBlack30,
                              padding: const EdgeInsets.all(12),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              elevation: 6,
                            ),
                            child: Icon(
                              CupertinoIcons.arrow_right_arrow_left,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : meshBlackDefault,
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
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shadowColor: meshBlack30,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                          ),
                          elevation: 6,
                        ),
                        icon: Icon(
                          CupertinoIcons.add,
                          size: 17,
                          color: Theme.of(context)
                              .extension<CustomColors>()
                              ?.backgroundSingleLayer,
                        ),
                        label: Text(
                          'add'.tr,
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.backgroundSingleLayer,
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'editLeaveAlertContent'.tr,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Get.back(),
            child: PlatformText(
              'continueEditing'.tr,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).extension<CustomColors>()?.blue,
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
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
