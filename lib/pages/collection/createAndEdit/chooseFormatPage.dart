import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/chooseFormatPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/folder/sortStoryPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/editTimelinePage.dart';
import 'package:readr/pages/collection/shared/timelineItemWidget.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/services/collectionService.dart';

class ChooseFormatPage extends GetView<ChooseFormatPageController> {
  final bool isEdit;
  final bool isQuickCreate;
  final List<CollectionPick> chooseStoryList;
  final CollectionFormat initFormat;
  final Collection? collection;
  late final List<TimelineCollectionPick> timelineCollectionPick;
  late final List<FolderCollectionPick> folderCollectionPick;
  ChooseFormatPage(
    this.chooseStoryList, {
    this.isEdit = false,
    this.isQuickCreate = false,
    this.initFormat = CollectionFormat.folder,
    this.collection,
  }) {
    timelineCollectionPick = List<TimelineCollectionPick>.from(
        chooseStoryList.map((e) =>
            TimelineCollectionPick.fromCollectionPickWithNewsListItem(e)));
    folderCollectionPick = List<FolderCollectionPick>.from(
        chooseStoryList.map((e) => FolderCollectionPick.fromCollectionPick(e)));
  }

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
            backgroundColor: Theme.of(context).backgroundColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWanderingCubes(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primaryLv1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'creatingCollection'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv1,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: _buildBar(context),
          body: _buildBody(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      title: Text(
        'collectionType'.tr,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: true,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (isQuickCreate)
          Obx(
            () => TextButton(
              child: Text(
                controller.format.value == CollectionFormat.folder
                    ? 'create'.tr
                    : 'nextStep'.tr,
                style: TextStyle(
                  color: Theme.of(context).extension<CustomColors>()?.blue,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                switch (controller.format.value) {
                  case CollectionFormat.folder:
                    controller.createCollection();
                    break;
                  case CollectionFormat.timeline:
                    Get.to(() => EditTimelinePage(timelineCollectionPick));
                    break;
                }
              },
            ),
          ),
        if (isEdit)
          Obx(
            () {
              if (controller.format.value != initFormat) {
                return TextButton(
                  child: Text(
                    'finish'.tr,
                    style: TextStyle(
                      color: Theme.of(context).extension<CustomColors>()?.blue,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    bool check = await _showChangeAlertDialog(context) ?? false;
                    if (check) {
                      chooseStoryList.sort((a, b) => b
                          .newsListItem!.publishedDate
                          .compareTo(a.newsListItem!.publishedDate));
                      Get.back();
                      switch (controller.format.value) {
                        case CollectionFormat.folder:
                          Get.off(
                            () => SortStoryPage(
                              folderCollectionPick,
                              isChangeFormat: true,
                              collection: collection,
                            ),
                            fullscreenDialog: true,
                          );

                          break;
                        case CollectionFormat.timeline:
                          Get.off(
                            () => EditTimelinePage(
                              timelineCollectionPick,
                              isChangeFormat: true,
                              collection: collection,
                            ),
                            fullscreenDialog: true,
                          );

                          break;
                      }
                    }
                  },
                );
              }

              return Container();
            },
          ),
        if (!isQuickCreate && !isEdit)
          TextButton(
            child: Text(
              'nextStep'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.blue,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              switch (controller.format.value) {
                case CollectionFormat.folder:
                  Get.to(() => SortStoryPage(folderCollectionPick));
                  break;
                case CollectionFormat.timeline:
                  Get.to(() => EditTimelinePage(timelineCollectionPick));
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
            previewWidget = _timelinePreviewWidget(context);
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
                    'selectCollectionType'.tr,
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
          NewsListItemWidget(folderCollectionPick[index].news),
      separatorBuilder: (context, index) => const Divider(
        thickness: 1,
        height: 36,
        indent: 20,
        endIndent: 20,
      ),
      itemCount: chooseStoryList.length,
    );
  }

  Widget _timelinePreviewWidget(BuildContext context) {
    List<TimelineCollectionPick> timelineStoryList = timelineCollectionPick;
    if (isEdit) {
      timelineStoryList
          .sort((a, b) => b.news.publishedDate.compareTo(a.news.publishedDate));
    }
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => TimelineItemWidget(
          timelineStoryList[index],
          key: Key(timelineStoryList[index].id),
          previousTimelineStory:
              index == 0 ? null : timelineStoryList[index - 1],
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
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
            title = 'folder'.tr;
            description = 'folderDescription'.tr;
            break;
          case CollectionFormat.timeline:
            iconImage = timelineIconSvg;
            title = 'timeline'.tr;
            description = 'timelineDescription'.tr;
            break;
        }
        return InkWell(
          hoverColor: meshBlack30,
          splashColor: meshBlack30,
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
                    color: meshBlack20,
                    blurRadius: 16,
                  ),
                  const BoxShadow(
                    color: meshBlack30,
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
                              : meshBlack50,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: meshBlack87,
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
                          color: meshBlack50,
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

  Future<bool?> _showChangeAlertDialog(BuildContext context) async {
    return await showPlatformDialog<bool>(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(
          'changeCollectionTypeAlertTitle'.tr,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).extension<CustomColors>()?.primaryLv1,
          ),
        ),
        content: Text(
          'changeCollectionTypeAlertContent'.tr,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<CustomColors>()?.primaryLv1,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Get.back<bool>(result: true),
            child: PlatformText(
              'comfirmChangeCollectionType'.tr,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          ),
          PlatformDialogAction(
            onPressed: () => Get.back<bool>(result: false),
            child: PlatformText(
              'cancel'.tr,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).extension<CustomColors>()?.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
