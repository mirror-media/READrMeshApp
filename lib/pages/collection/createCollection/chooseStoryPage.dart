import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionStoryItem.dart';
import 'package:readr/pages/collection/createCollection/titleAndOg/inputTitlePage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/services/collectionService.dart';

class ChooseStoryPage extends StatelessWidget {
  final CreateCollectionController controller =
      Get.put(CreateCollectionController(CollectionService()));
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedList.isNotEmpty) {
          return await _showLeaveAlertDialog(context) ?? false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildBar(context),
        body: Obx(
          () {
            if (controller.isError.isTrue) {
              return ErrorPage(
                error: controller.error,
                onPressed: () => controller.fetchPickAndBookmark(),
                hideAppbar: true,
              );
            }

            if (controller.isLoading.isFalse) {
              return _buildContent(context);
            }

            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
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
        onPressed: () async {
          if (controller.selectedList.isNotEmpty) {
            if (await _showLeaveAlertDialog(context) ?? false) {
              Get.back();
            }
          } else {
            Get.back();
          }
        },
      ),
      title: Obx(
        () {
          String title = '建立集錦';
          if (controller.selectedList.isNotEmpty) {
            title = '已選${controller.selectedList.length}篇';
          }
          return Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: readrBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      actions: [
        Obx(
          () {
            if (controller.selectedList.isNotEmpty) {
              return TextButton(
                child: const Text(
                  '下一步',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  controller.selectedList.sort((a, b) =>
                      b.news!.publishedDate.compareTo(a.news!.publishedDate));
                  for (var selectedItem in controller.selectedList) {
                    if (selectedItem.news!.heroImageUrl != null) {
                      controller.collectionOgUrlOrPath.value =
                          selectedItem.news!.heroImageUrl!;
                      break;
                    }
                  }
                  Get.to(() => InputTitlePage());
                },
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Future<bool?> _showLeaveAlertDialog(BuildContext context) async {
    return await showPlatformDialog<bool>(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text(
          '確認要退出編輯？',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '系統不會儲存您所做的變更',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Get.back<bool>(result: true),
            child: PlatformText(
              '退出',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.red,
              ),
            ),
          ),
          PlatformDialogAction(
            onPressed: () => Get.back<bool>(result: false),
            child: PlatformText(
              '繼續編輯',
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

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: GestureDetector(
              onTap: () async {
                await _showFilterBottomSheet(context);
              },
              child: Row(
                children: [
                  Obx(
                    () {
                      String text = '精選文章及書籤';
                      if (controller.showPicked.isFalse) {
                        text = '書籤';
                      } else if (controller.showBookmark.isFalse) {
                        text = '精選文章';
                      }
                      return Text(
                        text,
                        style: const TextStyle(
                          color: readrBlack87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.expand_more_outlined,
                    color: readrBlack30,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                List<CollectionStory> showList;
                if (controller.showPicked.isTrue &&
                    controller.showBookmark.isTrue) {
                  showList = controller.pickAndBookmarkList;
                } else if (controller.showPicked.isTrue) {
                  showList = controller.pickedList;
                } else {
                  showList = controller.bookmarkList;
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    return _buildListItem(showList[index]);
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: readrBlack10,
                      thickness: 1,
                      height: 1,
                      indent: 44,
                    );
                  },
                  itemCount: showList.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(CollectionStory collectionStory) {
    return Obx(
      () => CheckboxListTile(
        value: controller.selectedList
            .any((element) => element.news!.id == collectionStory.news!.id),
        dense: true,
        onChanged: (value) {
          if (value != null && value) {
            controller.selectedList.add(collectionStory);
          } else {
            controller.selectedList.removeWhere(
                (element) => element.news!.id == collectionStory.news!.id);
          }
        },
        activeColor: readrBlack87,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.only(left: 0, top: 16, bottom: 20),
        title: CollectionStoryItem(collectionStory),
      ),
    );
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    bool showPicked = controller.showPicked.value;
    bool showBookmark = controller.showBookmark.value;
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(20),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: readrBlack20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '新聞來源',
                    style: TextStyle(
                      color: readrBlack50,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: showPicked,
                  dense: true,
                  onChanged: (value) {
                    setState(() {
                      showPicked = value!;
                    });
                  },
                  activeColor: readrBlack87,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.only(left: 12),
                  title: const Text(
                    '精選文章',
                    style: TextStyle(
                      color: readrBlack87,
                      fontSize: 16,
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: showBookmark,
                  dense: true,
                  onChanged: (value) {
                    setState(() {
                      showBookmark = value!;
                    });
                  },
                  activeColor: readrBlack87,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.only(left: 12),
                  title: const Text(
                    '書籤',
                    style: TextStyle(
                      color: readrBlack87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Divider(
                  color: readrBlack10,
                  height: 0.5,
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: ElevatedButton(
                    onPressed: !showPicked && !showBookmark
                        ? null
                        : () {
                            controller.showPicked.value = showPicked;
                            controller.showBookmark.value = showBookmark;
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      primary: readrBlack87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      '篩選',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
