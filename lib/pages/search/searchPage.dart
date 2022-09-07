import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/searchPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/collection/smallCollectionItem.dart';
import 'package:readr/pages/search/allCollectionResultPage.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/services/searchService.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SearchPage extends GetView<SearchPageController> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Get.put(SearchPageController(SearchService()));
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 16),
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: readrBlack,
            ),
            onPressed: () => Get.back(),
          ),
          leadingWidth: 40,
          titleSpacing: 0,
          title: _searchBar(context),
          toolbarHeight: kToolbarHeight + 10,
        ),
        body: GetBuilder<SearchPageController>(
          builder: (controller) {
            if (controller.error != null) {
              return ErrorPage(
                error: controller.error,
                onPressed: () => controller.search(controller.keyWord),
                hideAppbar: true,
              );
            } else if (controller.isLoading.isTrue) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else if (controller.newsResultList.isNotEmpty) {
              return _searchResult();
            } else if (controller.noResult) {
              return _noResultWidget();
            }
            return _searchHistory(context);
          },
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        autofocus: true,
        controller: controller.textController,
        onSubmitted: (value) => controller.search(value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            CupertinoIcons.search,
            size: 22,
            color: readrBlack30,
          ),
          contentPadding: const EdgeInsets.fromLTRB(5.5, 8, 12, 8),
          hintText: 'searchBarHintText'.tr,
          hintStyle: const TextStyle(
            color: readrBlack30,
            fontSize: 14,
          ),
          filled: true,
          fillColor: const Color(0xffF6F6FB),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
            borderSide: BorderSide(color: Color(0xffF6F6FB)),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
            borderSide: BorderSide(color: Color(0xffF6F6FB)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
            borderSide: BorderSide(color: Color(0xffF6F6FB)),
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

  Widget _searchHistory(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (controller.searchHistoryList.isNotEmpty) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'searchHistory'.tr,
                    style: TextStyle(
                      fontWeight:
                          GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                      fontSize: 18,
                      color: readrBlack87,
                      fontFamily: 'PingFang TC',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.searchHistoryList.clear();
                      controller.update();
                    },
                    child: Text(
                      'clearAllHistory'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container();
        }),
        GetBuilder<SearchPageController>(
          builder: (controller) {
            if (controller.searchHistoryList.isEmpty) {
              return Container();
            }

            return Expanded(
              child: AnimatedList(
                key: _key,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index, animation) => FadeTransition(
                  opacity: animation,
                  child: ListTile(
                    tileColor: Colors.white,
                    textColor: readrBlack87,
                    iconColor: readrBlack30,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    title: Text(
                      controller.searchHistoryList[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: GestureDetector(
                      onTap: () => _removeItem(
                          index, context, controller.searchHistoryList[index]),
                      child: const Icon(
                        CupertinoIcons.minus_circle,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      controller.textController.text =
                          controller.searchHistoryList[index];
                      controller.search(controller.searchHistoryList[index]);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    shape: const Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                ),
                initialItemCount: controller.searchHistoryList.length,
              ),
            );
          },
        ),
      ],
    );
  }

  void _removeItem(int index, BuildContext context, String title) async {
    AnimatedList.of(context).removeItem(index, (_, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: ListTile(
            tileColor: Colors.white,
            textColor: readrBlack87,
            iconColor: readrBlack30,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            shape: const Border(
                bottom: BorderSide(width: 0.5, color: Colors.black12)),
          ),
        ),
      );
    }, duration: const Duration(milliseconds: 150));

    controller.searchHistoryList.removeAt(index);
  }

  Widget _noResultWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ExtendedText.rich(
        TextSpan(
          text: 'noResultPrefix'.tr,
          style: const TextStyle(
            color: readrBlack50,
          ),
          children: [
            TextSpan(
              text: controller.keyWord,
              style: const TextStyle(
                color: readrBlack87,
              ),
            ),
            TextSpan(
              text: 'noResultSuffix'.tr,
              style: const TextStyle(
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

  Widget _searchResult() {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Obx(
          () {
            if (controller.collectionResultList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'allCollections'.tr,
                    style: TextStyle(
                      fontWeight:
                          GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                      fontSize: 18,
                      color: readrBlack87,
                      fontFamily: 'PingFang TC',
                    ),
                  ),
                  Obx(
                    () {
                      if (controller.collectionResultList.length < 5) {
                        return Container();
                      }
                      return TextButton(
                        onPressed: () =>
                            Get.to(() => AllCollectionResultPage()),
                        child: Text(
                          'viewAll'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: readrBlack50,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        _buildCollectionList(),
        Obx(
          () {
            if (controller.newsResultList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Text(
                'allNews'.tr,
                style: TextStyle(
                  color: readrBlack87,
                  fontSize: 18,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  fontFamily: 'PingFang TC',
                ),
              ),
            );
          },
        ),
        _buildNewsStoryList(),
      ],
    );
  }

  Widget _buildNewsStoryList() {
    return Obx(
      () => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          if (index == controller.newsResultList.length) {
            if (controller.noMoreNews.isTrue) {
              return Container();
            }

            return VisibilityDetector(
              key: const Key('searchPageNewsLoadingMore'),
              onVisibilityChanged: (visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 50 &&
                    controller.isLoadingMoreNews.isFalse) {
                  controller.loadMoreNews();
                }
              },
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          return NewsListItemWidget(
            controller.newsResultList[index],
            key: Key(controller.newsResultList[index].id),
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.newsResultList.length - 1) {
            return const SizedBox(
              height: 36,
            );
          }
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: controller.newsResultList.length + 1,
      ),
    );
  }

  Widget _buildCollectionList() {
    return Obx(
      () {
        if (controller.collectionResultList.isEmpty) {
          return Container();
        }

        int itemCount;
        if (controller.collectionResultList.length >= 5) {
          itemCount = 5;
        } else {
          itemCount = controller.collectionResultList.length;
        }

        return SizedBox(
          height: 270,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              if (index == 4) {
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.fromLTRB(12, 31, 12, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SvgPicture.asset(
                            threeStarSvg,
                            width: context.width,
                          ),
                        ),
                        const SizedBox(height: 31),
                        ExtendedText.rich(
                          TextSpan(
                            text: 'viewAllCollectionResultPrefix'.tr,
                            style: const TextStyle(
                              color: readrBlack50,
                            ),
                            children: [
                              TextSpan(
                                text: controller.keyWord,
                                style: const TextStyle(
                                  color: readrBlack87,
                                ),
                              ),
                              TextSpan(
                                text: 'viewAllCollectionResultSuffix'.tr,
                                style: const TextStyle(
                                  color: readrBlack50,
                                ),
                              ),
                            ],
                          ),
                          joinZeroWidthSpace: true,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflowWidget: const TextOverflowWidget(
                            position: TextOverflowPosition.middle,
                            align: TextOverflowAlign.left,
                            child: Text(
                              '...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: readrBlack87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                Get.to(() => AllCollectionResultPage()),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: readrBlack87, width: 1),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'viewAll'.tr,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                color: readrBlack87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SmallCollectionItem(
                controller.collectionResultList[index],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: itemCount,
          ),
        );
      },
    );
  }
}
