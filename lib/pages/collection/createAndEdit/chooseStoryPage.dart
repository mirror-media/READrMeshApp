import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/collection/createAndEdit/chooseStoryPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/collectionStoryItem.dart';
import 'package:readr/pages/collection/createAndEdit/folder/sortStoryPage.dart';
import 'package:readr/pages/collection/createAndEdit/timeline/editTimelinePage.dart';
import 'package:readr/pages/collection/createAndEdit/titleAndOgPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/services/collectionService.dart';
import 'package:readr/services/searchService.dart';

class ChooseStoryPage extends GetView<ChooseStoryPageController> {
  final bool isEdit;
  final List<String>? pickedStoryIds;
  final bool isAddToEmpty;
  final Collection? collection;
  const ChooseStoryPage({
    this.isEdit = false,
    this.pickedStoryIds,
    this.isAddToEmpty = false,
    this.collection,
  });

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
          backgroundColor: Theme.of(context).backgroundColor,
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
                                    String text = 'picksAndBookmarks'.tr;
                                    if (controller.showPicked.isFalse &&
                                        controller.showBookmark.isFalse) {
                                      text = 'allNews'.tr;
                                    } else if (controller.showPicked.isFalse) {
                                      text = 'bookmarks'.tr;
                                    } else if (controller
                                        .showBookmark.isFalse) {
                                      text = 'pickedArticles'.tr;
                                    }
                                    return Text(
                                      text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Theme.of(context)
                                      .extension<CustomColors>()
                                      ?.primaryLv4,
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
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primaryLv4,
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
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                hintText: 'searchAllNews'.tr,
                                hintStyle:
                                    Theme.of(context).textTheme.labelMedium,
                                filled: true,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6.0)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6.0)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6.0)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                ),
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
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
      elevation: 0.5,
      centerTitle: GetPlatform.isIOS,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Theme.of(context).appBarTheme.foregroundColor,
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
          String title = isEdit ? 'addNewArticle'.tr : 'createCollection'.tr;
          if (controller.selectedList.isNotEmpty) {
            title =
                '${'chooseStoryPageSelectTitlePrefix'.tr}${controller.selectedList.length}${'chooseStoryPageSelectTitleSuffix'.tr}';
          }
          return Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: Theme.of(context).appBarTheme.foregroundColor,
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
                  isEdit ? 'finish'.tr : 'nextStep'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Theme.of(context).extension<CustomColors>()?.blue,
                  ),
                ),
                onPressed: () {
                  controller.selectedList.sort((a, b) => b
                      .newsListItem!.publishedDate
                      .compareTo(a.newsListItem!.publishedDate));
                  if (isEdit) {
                    Get.back(result: controller.selectedList);
                  } else if (isAddToEmpty) {
                    switch (collection?.format) {
                      case CollectionFormat.folder:
                        Get.off(
                          () => SortStoryPage(
                            List<FolderCollectionPick>.from(
                                controller.selectedList.map((element) =>
                                    FolderCollectionPick.fromCollectionPick(
                                        element))),
                            isAddToEmpty: true,
                            collection: collection,
                          ),
                        );
                        break;
                      case CollectionFormat.timeline:
                        Get.off(
                          () => EditTimelinePage(
                            List<TimelineCollectionPick>.from(controller
                                .selectedList
                                .map((e) => TimelineCollectionPick
                                    .fromCollectionPickWithNewsListItem(e))),
                            isAddToEmpty: true,
                            collection: collection,
                          ),
                        );
                        break;
                      case null:
                        break;
                    }
                  } else {
                    List<String> ogImageUrlList = [];
                    for (var collectionStory in controller.selectedList) {
                      ogImageUrlList.addIf(
                          collectionStory.newsListItem!.heroImageUrl != null,
                          collectionStory.newsListItem!.heroImageUrl!);
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
        title: Text(
          'chooseStoryPageLeaveAlertTitle'.tr,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
        ),
        content: Text(
          'chooseStoryPageLeaveAlertContent'.tr,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: PlatformText(
              'quit'.tr,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(
      () {
        List<CollectionPick> showList;
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
          return _noResultWidget(context);
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

            return _buildListItem(context, showList[index]);
          },
          separatorBuilder: (context, index) {
            if (index == showList.length - 1) {
              return Container();
            }
            return const Divider(
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

  Widget _noResultWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: ExtendedText.rich(
        TextSpan(
          text: 'noNewsResultPrefix'.tr,
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()?.primary500,
          ),
          children: [
            TextSpan(
              text: controller.searchWord,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary700,
              ),
            ),
            TextSpan(
              text: 'noNewsResultSuffix'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary500,
              ),
            ),
          ],
        ),
        joinZeroWidthSpace: true,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).extension<CustomColors>()?.primary700,
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, CollectionPick collectionStory) {
    return Obx(
      () => CheckboxListTile(
        value: controller.selectedList
            .any((element) => element.pickNewsId == collectionStory.pickNewsId),
        dense: true,
        onChanged: (value) {
          if (value != null && value) {
            controller.selectedList.add(collectionStory);
          } else {
            controller.selectedList.removeWhere(
                (element) => element.pickNewsId == collectionStory.pickNewsId);
          }
        },
        activeColor: Theme.of(context).extension<CustomColors>()?.primary700,
        checkColor: Theme.of(context).backgroundColor,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.only(left: 0, top: 16, bottom: 20),
        title: CollectionStoryItem(collectionStory.newsListItem!),
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
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Theme.of(context).backgroundColor,
                  ),
                  margin: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'newsSource'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary500,
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
                  activeColor:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  checkColor: Theme.of(context).backgroundColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.only(left: 12),
                  title: Text(
                    'pickedArticles'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
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
                  activeColor:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  checkColor: Theme.of(context).backgroundColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.only(left: 12),
                  title: Text(
                    'bookmarks'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Divider(
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
                      backgroundColor: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
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
                    child: Text(
                      'filter'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).backgroundColor,
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
