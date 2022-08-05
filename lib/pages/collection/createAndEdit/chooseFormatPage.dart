import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/chooseFormatPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/timelineStory.dart';
import 'package:readr/pages/collection/createAndEdit/folder/sortStoryPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/timeDimensionPage.dart';
import 'package:readr/pages/collection/shared/timelineItemWidget.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/services/collectionService.dart';

class ChooseFormatPage extends GetView<ChooseFormatPageController> {
  final bool isEdit;
  final bool isQuickCreate;
  final List<CollectionStory> chooseStoryList;
  final CollectionFormat initFormat;
  const ChooseFormatPage(
    this.chooseStoryList, {
    this.isEdit = false,
    this.isQuickCreate = false,
    this.initFormat = CollectionFormat.folder,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(ChooseFormatPageController(
      CollectionService(),
      chooseStoryList,
      initFormat,
    ));
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
          appBar: _buildBar(),
          body: _buildBody(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        '集錦類型',
        style: TextStyle(
          fontSize: 18,
          color: readrBlack,
        ),
      ),
      centerTitle: true,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack87,
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (isQuickCreate)
          Obx(
            () => TextButton(
              child: Text(
                controller.format.value == CollectionFormat.folder
                    ? '建立'
                    : '下一步',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                switch (controller.format.value) {
                  case CollectionFormat.folder:
                    controller.createCollection();
                    break;
                  case CollectionFormat.timeline:
                    Get.to(() => TimeDimensionPage(List<TimelineStory>.from(
                        chooseStoryList.map(
                            (e) => TimelineStory.fromCollectionStory(e)))));
                    break;
                }
              },
            ),
          ),
        if (isEdit)
          TextButton(
            child: const Text(
              '完成',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
            onPressed: () => Get.back(result: controller.format.value),
          ),
        if (!isQuickCreate && !isEdit)
          TextButton(
            child: const Text(
              '下一步',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              switch (controller.format.value) {
                case CollectionFormat.folder:
                  Get.to(() => SortStoryPage(chooseStoryList));
                  break;
                case CollectionFormat.timeline:
                  Get.to(() => TimeDimensionPage(List<TimelineStory>.from(
                      chooseStoryList
                          .map((e) => TimelineStory.fromCollectionStory(e)))));
                  break;
              }
            },
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(
      () {
        Widget previewWidget;
        switch (controller.format.value) {
          case CollectionFormat.folder:
            previewWidget = _folderPreviewWidget();
            break;
          case CollectionFormat.timeline:
            previewWidget = _timelinePreviewWidget();
            break;
        }

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomLeft,
          children: [
            IgnorePointer(
              child: previewWidget,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [0.5, 0.75],
                ),
              ),
              height: 347,
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '選擇集錦類型',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                      fontFamily: 'PingFang TC',
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _formatButton(context, CollectionFormat.folder),
                      const SizedBox(
                        width: 12,
                      ),
                      _formatButton(context, CollectionFormat.timeline),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _folderPreviewWidget() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) =>
          NewsListItemWidget(chooseStoryList[index].news),
      separatorBuilder: (context, index) => const Divider(
        color: readrBlack10,
        thickness: 1,
        height: 36,
        indent: 20,
        endIndent: 20,
      ),
      itemCount: chooseStoryList.length,
    );
  }

  Widget _timelinePreviewWidget() {
    List<TimelineStory> timelineStoryList = List<TimelineStory>.from(
        chooseStoryList.map((e) => TimelineStory.fromCollectionStory(e)));
    return Container(
      color: timelineBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => TimelineItemWidget(
          timelineStoryList[index],
          key: Key(timelineStoryList[index].id),
          previousTimelineStory:
              index == 0 ? null : timelineStoryList[index - 1],
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 20,
        ),
        itemCount: timelineStoryList.length,
      ),
    );
  }

  Widget _formatButton(BuildContext context, CollectionFormat format) {
    return Obx(
      () {
        bool isSelected = format == controller.format.value;
        String iconImage;
        String title;
        String description;
        switch (format) {
          case CollectionFormat.folder:
            iconImage = folderIconSvg;
            title = '資料夾';
            description = '打包多篇新聞';
            break;
          case CollectionFormat.timeline:
            iconImage = timelineIconSvg;
            title = '時間軸';
            description = '自訂時間排序';
            break;
        }
        return InkWell(
          hoverColor: readrBlack30,
          splashColor: readrBlack30,
          onTap: () => controller.format.value = format,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              boxShadow: [
                if (isSelected)
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 12,
                  ),
                if (!isSelected) ...[
                  const BoxShadow(
                    color: readrBlack20,
                    blurRadius: 16,
                  ),
                  const BoxShadow(
                    color: readrBlack30,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ],
              color: isSelected
                  ? Colors.white
                  : const Color.fromRGBO(255, 255, 255, 0.87),
            ),
            height: 143,
            width: (context.width - 40 - 12) / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          iconImage,
                          color: isSelected
                              ? const Color.fromRGBO(0, 122, 255, 1)
                              : readrBlack50,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: readrBlack87,
                          fontSize: 14,
                          fontWeight: GetPlatform.isIOS
                              ? FontWeight.w500
                              : FontWeight.w600,
                          fontFamily: 'PingFang TC',
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: readrBlack50,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => controller.format.value = format,
                    activeColor: const Color.fromRGBO(0, 122, 255, 1),
                    shape: const CircleBorder(),
                    side: const BorderSide(width: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
