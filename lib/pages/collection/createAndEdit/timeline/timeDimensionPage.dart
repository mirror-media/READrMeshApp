import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/collection/createAndEdit/timeDimensionPageController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/chooseFormatPage.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/customTimePage.dart';
import 'package:readr/pages/collection/shared/timelineItemWidget.dart';
import 'package:readr/services/collectionService.dart';

class TimeDimensionPage extends GetView<TimeDimensionPageController> {
  final bool isEdit;
  final bool isChangeFormat;
  final List<TimelineCollectionPick> timelineStoryList;
  final Collection? collection;
  final bool isAddToEmpty;
  const TimeDimensionPage(
    this.timelineStoryList, {
    this.isEdit = false,
    this.isChangeFormat = false,
    this.isAddToEmpty = false,
    this.collection,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(TimeDimensionPageController(
      CollectionService(),
      timelineStoryList,
      collection: collection,
    ));
    if (isChangeFormat || isAddToEmpty) {
      controller.hasChange.value = true;
    }
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasChange.isTrue || isChangeFormat) {
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
                          ? '更新集錦中'
                          : '集錦建立中',
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
            backgroundColor: collectionBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0.5,
              leading: (isEdit || isChangeFormat)
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
                        if (controller.hasChange.isTrue || isChangeFormat) {
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
              title: const Text(
                '時間維度',
                style: TextStyle(
                  fontSize: 18,
                  color: readrBlack,
                ),
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
                            ? '儲存'
                            : '建立',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () {
                        if (isEdit || isAddToEmpty || isChangeFormat) {
                          controller.updateCollectionPicks(isAddToEmpty);
                        } else {
                          controller.createCollection();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            body: _buildBody(context),
            floatingActionButton: (isEdit || isChangeFormat)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: JustTheTooltip(
                          content: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Text(
                              '更換集錦類型',
                              style: TextStyle(
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
                          onDismiss: () {
                            Get.find<SharedPreferencesService>()
                                .prefs
                                .setBool('firstTimeEditTimeline', false);
                          },
                          child: ElevatedButton(
                            onPressed: () => Get.to(
                              () => ChooseFormatPage(
                                controller.timelineStoryList,
                                isEdit: true,
                                initFormat: CollectionFormat.timeline,
                                collection: collection,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: const Color(0xff04295E),
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
                          List<CollectionPick> newCollectionStory =
                              await Get.to(() => ChooseStoryPage(
                                        isEdit: isEdit || isChangeFormat,
                                        pickedStoryIds: List<String>.from(
                                          controller.timelineStoryList.map(
                                            (element) => element.news.id,
                                          ),
                                        ),
                                      )) ??
                                  [];
                          controller.timelineStoryList.addAll(
                              List<TimelineCollectionPick>.from(
                                  newCollectionStory.map((e) =>
                                      TimelineCollectionPick.fromCollectionPick(
                                          e))));
                          controller.sortListByTime();
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
                        label: const Text(
                          '新增',
                          style: TextStyle(
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

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => CupertinoSlidingSegmentedControl<TimeDimension>(
                onValueChanged: (value) async {
                  if (value != null) {
                    if (controller.editItemTime) {
                      await _showChangeDimensionAlertDialog(context, value);
                    } else {
                      controller.updateTimeDimension(value, isEdit);
                    }
                  }
                },
                groupValue: controller.timeDimension.value,
                children: {
                  TimeDimension.yearAndDate: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '年份與日期',
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.timeDimension.value ==
                                TimeDimension.yearAndDate
                            ? readrBlack87
                            : readrBlack50,
                      ),
                    ),
                  ),
                  TimeDimension.onlyMonth: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '只有月份',
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.timeDimension.value ==
                                TimeDimension.onlyMonth
                            ? readrBlack87
                            : readrBlack50,
                      ),
                    ),
                  ),
                  TimeDimension.onlyYear: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '只有年份',
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.timeDimension.value ==
                                TimeDimension.onlyYear
                            ? readrBlack87
                            : readrBlack50,
                      ),
                    ),
                  )
                },
                padding: const EdgeInsets.all(4),
                thumbColor: Colors.white,
                backgroundColor: readrBlack10,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Get.to(
                    () => CustomTimePage(
                      controller.timelineStoryList[index],
                    ),
                    fullscreenDialog: true,
                  ),
                  child: TimelineItemWidget(
                    controller.timelineStoryList[index],
                    previousTimelineStory: index == 0
                        ? null
                        : controller.timelineStoryList[index - 1],
                    editMode: true,
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 8,
                ),
                itemCount: controller.timelineStoryList.length,
              ),
            ),
          ),
        ],
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
          '系統將不會儲存變更',
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

  Future<bool?> _showChangeDimensionAlertDialog(
      BuildContext context, TimeDimension newDimension) async {
    return await showPlatformDialog<bool>(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text(
          '確認變更時間維度？',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '系統將不會儲存先前的編輯紀錄',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () {
              controller.updateTimeDimension(newDimension, isEdit);
              controller.sortListByTime();
              controller.editItemTime = false;
              Get.back();
            },
            child: PlatformText(
              '確認變更',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.red,
              ),
            ),
          ),
          PlatformDialogAction(
            onPressed: () => Get.back(),
            child: PlatformText(
              '取消',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
