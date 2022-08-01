import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/collection/createAndEdit/chooseStoryPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionStoryItem.dart';
import 'package:readr/pages/collection/createAndEdit/titleAndOgPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/services/collectionService.dart';
import 'package:readr/services/searchService.dart';

class ChooseStoryPage extends GetView<ChooseStoryPageController> {
  final bool isEdit;
  final List<String>? pickedStoryIds;
  const ChooseStoryPage({this.isEdit = false, this.pickedStoryIds});

  @override
  Widget build(BuildContext context) {
    Get.put(ChooseStoryPageController(
      CollectionService(),
      SearchService(),
      pickedStoryIds: pickedStoryIds,
    ));
    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedList.isNotEmpty) {
          return await _showLeaveAlertDialog(context) ?? false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _showFilterBottomSheet(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () {
                                    String text = '精選文章及書籤';
                                    if (controller.showPicked.isFalse &&
                                        controller.showBookmark.isFalse) {
                                      text = '所有新聞';
                                    } else if (controller.showPicked.isFalse) {
                                      text = '書籤';
                                    } else if (controller
                                        .showBookmark.isFalse) {
                                      text = '精選文章';
                                    }
                                    return Text(
                                      text,
                                      style: TextStyle(
                                        color: readrBlack87,
                                        fontSize: 18,
                                        fontWeight: GetPlatform.isIOS
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                        fontFamily: 'PingFang TC',
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: readrBlack30,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.centerRight,
                            onPressed: () => controller.searchMode.toggle(),
                            icon: const Icon(
                              CupertinoIcons.search,
                            ),
                            iconSize: 26,
                            color: readrBlack30,
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () {
                        if (controller.searchMode.isTrue) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              autofocus: true,
                              onChanged: (text) =>
                                  controller.keyWord.value = text,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                hintText: '搜尋所有新聞...',
                                hintStyle: TextStyle(
                                  color: readrBlack30,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Color(0xffF6F6FB),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  borderSide:
                                      BorderSide(color: Color(0xffF6F6FB)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  borderSide:
                                      BorderSide(color: Color(0xffF6F6FB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  borderSide:
                                      BorderSide(color: Color(0xffF6F6FB)),
                                ),
                              ),
                              style: const TextStyle(
                                color: readrBlack87,
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    Expanded(
                      child: Obx(
                        () {
                          if (controller.isLoading.isFalse) {
                            return _buildContent(context);
                          }

                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
            await _showLeaveAlertDialog(context);
          } else {
            Get.back();
          }
        },
      ),
      title: Obx(
        () {
          String title = isEdit ? '加入新文章' : '建立集錦';
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
                child: Text(
                  isEdit ? '完成' : '下一步',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  controller.selectedList.sort((a, b) =>
                      b.news.publishedDate.compareTo(a.news.publishedDate));
                  if (isEdit) {
                    Get.back(result: controller.selectedList);
                  } else {
                    List<String> ogImageUrlList = [];
                    for (var collectionStory in controller.selectedList) {
                      ogImageUrlList.addIf(
                          collectionStory.news.heroImageUrl != null,
                          collectionStory.news.heroImageUrl!);
                    }
                    Get.to(() => TitleAndOgPage(
                          null,
                          ogImageUrlList.first,
                          ogImageUrlList,
                        ));
                  }
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
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: PlatformText(
              '退出',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.red,
              ),
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(
      () {
        List<CollectionStory> showList;
        bool noMore = false;
        if (controller.showPicked.isTrue && controller.showBookmark.isTrue) {
          showList = controller.pickAndBookmarkList;
          noMore =
              controller.noMorePick.value && controller.noMoreBookmark.value;
        } else if (controller.showPicked.isTrue) {
          showList = controller.pickedList;
          noMore = controller.noMorePick.value;
        } else if (controller.showBookmark.isTrue) {
          showList = controller.bookmarkList;
          noMore = controller.noMoreBookmark.value;
        } else {
          showList = controller.otherNewsList;
          noMore = controller.noMoreResults.value;
        }

        if (showList.isEmpty && controller.searchMode.isTrue) {
          return _noResultWidget();
        }

        return ListView.separated(
          key: Key(controller.searchWord),
          itemBuilder: (context, index) {
            if (index == showList.length) {
              if (noMore) {
                return Container();
              } else if (controller.isLoadingMore.isFalse) {
                if (controller.showPicked.isTrue ||
                    controller.showBookmark.isTrue) {
                  controller.loadMorePickAndBookmark(
                      keyWord: controller.searchWord);
                } else {
                  controller.searchAllNewsLoadMore();
                }
              }

              return const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return _buildListItem(showList[index]);
          },
          separatorBuilder: (context, index) {
            if (index == showList.length - 1) {
              return Container();
            }
            return const Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
              indent: 44,
            );
          },
          itemCount: showList.length + 1,
        );
      },
    );
  }

  Widget _noResultWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: ExtendedText.rich(
        TextSpan(
          text: '找不到包含「',
          style: const TextStyle(
            color: readrBlack50,
          ),
          children: [
            TextSpan(
              text: controller.searchWord,
              style: const TextStyle(
                color: readrBlack87,
              ),
            ),
            const TextSpan(
              text: '」的新聞，請換個關鍵字，再試一次。',
              style: TextStyle(
                color: readrBlack50,
              ),
            ),
          ],
        ),
        joinZeroWidthSpace: true,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildListItem(CollectionStory collectionStory) {
    return Obx(
      () => CheckboxListTile(
        value: controller.selectedList
            .any((element) => element.news.id == collectionStory.news.id),
        dense: true,
        onChanged: (value) {
          if (value != null && value) {
            controller.selectedList.add(collectionStory);
          } else {
            controller.selectedList.removeWhere(
                (element) => element.news.id == collectionStory.news.id);
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
    FocusManager.instance.primaryFocus?.unfocus();
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
                    onPressed: !showPicked &&
                            !showBookmark &&
                            controller.searchMode.isFalse
                        ? null
                        : () {
                            if (!showPicked &&
                                !showBookmark &&
                                (controller.showPicked.isTrue ||
                                    controller.showBookmark.isTrue)) {
                              controller.searchAllNews();
                            } else if (controller.showPicked.isFalse &&
                                controller.showBookmark.isFalse &&
                                (showPicked || showBookmark)) {
                              controller.fetchPickAndBookmark(
                                keyWord: controller.keyWord.value,
                              );
                            }
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
