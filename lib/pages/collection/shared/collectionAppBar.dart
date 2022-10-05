import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/comment/commentInputBoxController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/descriptionPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/editTimelinePage.dart';
import 'package:readr/pages/collection/createAndEdit/titleAndOgPage.dart';
import 'package:readr/pages/collection/createAndEdit/folder/sortStoryPage.dart';
import 'package:readr/pages/shared/reportAlertDialog.dart';
import 'package:share_plus/share_plus.dart';

class CollectionAppBar extends GetView<CollectionPageController>
    implements PreferredSizeWidget {
  final Collection collection;
  const CollectionAppBar(this.collection);

  @override
  String get tag => collection.id;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: GetPlatform.isIOS,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        onPressed: () async {
          if (Get.isRegistered<CommentInputBoxController>(
                  tag: collection.controllerTag) &&
              Get.find<CommentInputBoxController>(tag: collection.controllerTag)
                  .hasInput
                  .isTrue) {
            await showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: Text(
                  'deleteAlertTitle'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primaryLv1,
                  ),
                ),
                content: Text(
                  'leaveAlertContent'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primaryLv1,
                  ),
                ),
                actions: [
                  PlatformDialogAction(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    child: PlatformText(
                      'deleteComment'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.redText,
                      ),
                    ),
                  ),
                  PlatformDialogAction(
                    onPressed: () => Get.back(),
                    child: PlatformText(
                      'continueInput'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            Theme.of(context).extension<CustomColors>()?.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Get.back();
          }
        },
      ),
      title: Text(
        'collection'.tr,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        GetBuilder<CollectionPageController>(
          tag: collection.id,
          builder: (controller) {
            if (!controller.isError && !controller.isLoading) {
              return IconButton(
                icon: Icon(
                  PlatformIcons(context).share,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  size: 26,
                ),
                tooltip: 'share'.tr,
                onPressed: () async {
                  String shareLink =
                      await DynamicLinkHelper.createCollectionLink(collection);
                  Share.shareWithResult(shareLink).then((value) {
                    if (value.status == ShareResultStatus.success) {
                      logShare('collection', collection.id, value.raw);
                    }
                  });
                },
              );
            }

            return Container();
          },
        ),
        GetBuilder<CollectionPageController>(
          tag: collection.id,
          builder: (controller) {
            if (!controller.isError && !controller.isLoading) {
              return Obx(
                () {
                  if (Get.find<UserService>().isMember.isTrue &&
                      collection.creator.memberId ==
                          Get.find<UserService>().currentUser.memberId) {
                    return _editCollectionOptionButton(context);
                  }
                  return _reportCollectionOptionButton(context);
                },
              );
            }

            return Container();
          },
        ),
      ],
    );
  }

  Widget _editCollectionOptionButton(BuildContext context) {
    return PlatformPopupMenu(
      icon: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, left: 10),
        child: Icon(
          PlatformIcons(context).ellipsis,
          color: Theme.of(context).appBarTheme.foregroundColor,
          size: 26,
        ),
      ),
      options: [
        PopupMenuOption(
          label: 'editTitle'.tr,
          onTap: (option) => Get.to(
            () => TitleAndOgPage(
              Get.find<PickableItemController>(tag: collection.controllerTag)
                      .collectionTitle
                      .value ??
                  collection.title,
              Get.find<PickableItemController>(tag: collection.controllerTag)
                      .collectionHeroImageUrl
                      .value ??
                  collection.ogImageUrl,
              List<String>.from(controller.collectionPicks.map((element) {
                if (element.newsListItem!.heroImageUrl != null) {
                  return element.newsListItem!.heroImageUrl;
                }
              })),
              collection: collection,
              isEdit: true,
            ),
            fullscreenDialog: true,
          ),
        ),
        PopupMenuOption(
          label: 'editDescription'.tr,
          onTap: (option) => Get.to(
            () => DescriptionPage(
              collection: collection,
              description: controller.collectionDescription.value,
              isEdit: true,
            ),
          ),
        ),
        PopupMenuOption(
          label: 'editContentAndSorting'.tr,
          onTap: (option) {
            switch (controller.collectionFormat.value) {
              case CollectionFormat.folder:
                List<FolderCollectionPick> folderStoryList =
                    List<FolderCollectionPick>.from(
                        controller.collectionPicks.map(
                  (element) => FolderCollectionPick.fromCollectionPick(element),
                ));
                Get.to(
                  () => SortStoryPage(
                    folderStoryList,
                    collection: collection,
                    isEdit: true,
                  ),
                  fullscreenDialog: true,
                );
                break;
              case CollectionFormat.timeline:
                List<TimelineCollectionPick> timelineStoryList =
                    List<TimelineCollectionPick>.from(
                        controller.collectionPicks.map(
                  (element) => element as TimelineCollectionPick,
                ));

                Get.to(
                  () => EditTimelinePage(
                    timelineStoryList,
                    collection: collection,
                    isEdit: true,
                  ),
                  fullscreenDialog: true,
                );
                break;
            }
          },
        ),
        PopupMenuOption(
          label: 'deleteCollection'.tr,
          cupertino: (context, platform) => CupertinoPopupMenuOptionData(
            isDestructiveAction: true,
          ),
          material: (context, platform) => MaterialPopupMenuOptionData(
            child: Text(
              'deleteCollection'.tr,
              style: TextStyle(
                  color: Theme.of(context).extension<CustomColors>()?.redText),
            ),
          ),
          onTap: (option) async => await showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: Text(
                'deleteCollectionAlertTitle'.tr,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primaryLv1,
                ),
              ),
              content: Text(
                'deleteCollectionAlertDescription'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primaryLv1,
                ),
              ),
              actions: [
                PlatformDialogAction(
                  child: Text(
                    'delete'.tr,
                    style: TextStyle(
                      color:
                          Theme.of(context).extension<CustomColors>()?.redText,
                    ),
                  ),
                  onPressed: () async {
                    controller.deleteCollection();
                    Get.back();
                  },
                ),
                PlatformDialogAction(
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(
                      color: Theme.of(context).extension<CustomColors>()?.blue,
                    ),
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ],
      material: (context, platform) => MaterialPopupMenuData(
        padding: const EdgeInsets.only(right: 12, bottom: 8),
      ),
      cupertino: (context, platform) => CupertinoPopupMenuData(
        cancelButtonData: CupertinoPopupMenuCancelButtonData(
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Theme.of(context).extension<CustomColors>()?.blue,
            ),
          ),
          isDefaultAction: true,
        ),
      ),
    );
  }

  Widget _reportCollectionOptionButton(BuildContext context) {
    return PlatformPopupMenu(
      icon: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, left: 10),
        child: Icon(
          PlatformIcons(context).ellipsis,
          color: Theme.of(context).appBarTheme.foregroundColor,
          size: 26,
        ),
      ),
      options: [
        PopupMenuOption(
          label: 'reportCollection'.tr,
          onTap: (option) async => await showReportAlertDialog(context),
          cupertino: (context, platform) => CupertinoPopupMenuOptionData(
            isDestructiveAction: true,
          ),
          material: (context, platform) => MaterialPopupMenuOptionData(
            child: Text(
              'reportCollection'.tr,
              style: TextStyle(
                  color: Theme.of(context).extension<CustomColors>()?.redText),
            ),
          ),
        ),
      ],
      material: (context, platform) => MaterialPopupMenuData(
        padding: const EdgeInsets.only(right: 12, bottom: 8),
      ),
      cupertino: (context, platform) => CupertinoPopupMenuData(
        cancelButtonData: CupertinoPopupMenuCancelButtonData(
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Theme.of(context).extension<CustomColors>()?.blue,
            ),
          ),
          isDefaultAction: true,
        ),
      ),
    );
  }
}
