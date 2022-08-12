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
import 'package:readr/models/collection.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/descriptionPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/timeDimensionPage.dart';
import 'package:readr/pages/collection/createAndEdit/titleAndOgPage.dart';
import 'package:readr/pages/collection/createAndEdit/folder/sortStoryPage.dart';
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
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack,
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
                title: const Text(
                  '確定要刪除留言？',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: const Text(
                  '系統將不會儲存您剛剛輸入的內容',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                actions: [
                  PlatformDialogAction(
                    onPressed: () => Get.back(closeOverlays: true),
                    child: PlatformText(
                      '刪除留言',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  PlatformDialogAction(
                    onPressed: () => Get.back(),
                    child: PlatformText(
                      '繼續輸入',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
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
      title: const Text(
        '集錦',
        style: TextStyle(
          fontSize: 18,
          color: readrBlack,
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
                  color: readrBlack87,
                  size: 26,
                ),
                tooltip: '分享',
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
                  return Container();
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
          color: readrBlack87,
          size: 26,
        ),
      ),
      options: [
        PopupMenuOption(
          label: '修改標題',
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
          label: '修改敘述',
          onTap: (option) => Get.to(
            () => DescriptionPage(
              collection: collection,
              description: controller.collectionDescription.value,
              isEdit: true,
            ),
          ),
        ),
        PopupMenuOption(
          label: '編輯內容與排序',
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
                  (element) =>
                      TimelineCollectionPick.fromCollectionPick(element),
                ));

                Get.to(
                  () => TimeDimensionPage(
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
          label: '刪除集錦',
          cupertino: (context, platform) => CupertinoPopupMenuOptionData(
            isDestructiveAction: true,
          ),
          material: (context, platform) => MaterialPopupMenuOptionData(
            child: const Text(
              '刪除集錦',
              style: TextStyle(color: Colors.red),
            ),
          ),
          onTap: (option) async => await showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: const Text(
                '確認刪除集錦？',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text(
                '此動作無法復原',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              actions: [
                PlatformDialogAction(
                  child: const Text(
                    '刪除',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    controller.deleteCollection();
                    Get.back();
                  },
                ),
                PlatformDialogAction(
                  child: const Text(
                    '取消',
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
          child: const Text(
            '取消',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          isDefaultAction: true,
        ),
      ),
    );
  }
}
