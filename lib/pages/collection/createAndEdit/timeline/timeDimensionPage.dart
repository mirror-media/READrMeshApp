import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/timeDimensionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/timelineStory.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/customTimePage.dart';
import 'package:readr/pages/collection/shared/timelineItemWidget.dart';
import 'package:readr/services/collectionService.dart';

class TimeDimensionPage extends GetView<TimeDimensionPageController> {
  final bool isEdit;
  final List<TimelineStory> timelineStoryList;
  const TimeDimensionPage(this.timelineStoryList, {this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    Get.put(TimeDimensionPageController(
      CollectionService(),
      timelineStoryList,
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
            backgroundColor: timelineBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0.5,
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
                TextButton(
                  child: Text(
                    isEdit ? '儲存' : '建立',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: _buildBody(context),
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
                      controller.updateTimeDimension(value);
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
                    key: Key(controller.timelineStoryList[index].news.id +
                        index.toString()),
                    previousTimelineStory: index == 0
                        ? null
                        : controller.timelineStoryList[index - 1],
                    editMode: true,
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 20,
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
              controller.updateTimeDimension(newDimension);
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
