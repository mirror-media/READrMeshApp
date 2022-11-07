import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CollectionTabContent extends GetView<CollectionTabController> {
  final Member viewMember;
  const CollectionTabContent({
    required this.viewMember,
  });

  @override
  String get tag => viewMember.memberId;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<CollectionTabController>(tag: viewMember.memberId)) {
      controller.fetchCollecitionList();
    } else {
      Get.put(
        CollectionTabController(
          personalFileRepos: PersonalFileService(),
          viewMember: viewMember,
        ),
        tag: viewMember.memberId,
      );
    }

    return GetBuilder<CollectionTabController>(
      tag: viewMember.memberId,
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.initPage(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          if (controller.collectionList.isEmpty) {
            return _emptyWidget(context);
          }

          return Obx(() {
            if (Get.find<PersonalFilePageController>(tag: viewMember.memberId)
                .isBlock
                .isTrue) {
              return _emptyWidget(context);
            }

            return _buildContent(context);
          });
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget(BuildContext context) {
    return Obx(
      () {
        if (Get.find<UserService>().isMember.isTrue &&
            Get.find<UserService>().currentUser.memberId ==
                viewMember.memberId) {
          int pickCount =
              Get.find<PersonalFilePageController>(tag: viewMember.memberId)
                  .pickCount
                  .value;
          int bookmarkCount =
              Get.find<PersonalFilePageController>(tag: viewMember.memberId)
                  .bookmarkCount
                  .value;
          bool hasPickOrBookmark = pickCount + bookmarkCount > 0;

          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasPickOrBookmark
                        ? 'emptyCollectionDescription'.tr
                        : 'emptyCollectionWithNoPickOrBookmarkDescription'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary400,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (hasPickOrBookmark) {
                        Get.to(() => const ChooseStoryPage());
                      } else {
                        Get.until((route) => route.isFirst);
                        Get.find<RootPageController>().tabIndex.value = 1;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      hasPickOrBookmark
                          ? 'emptyCollectionButtonText'.tr
                          : 'emptyCollectionWithNoPickOrBookmarkButtonText'.tr,
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Text(
              'viewMemberNoCollection'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary400,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Obx(
              () {
                if (Get.find<UserService>().isMember.isTrue &&
                    Get.find<UserService>().currentUser.memberId ==
                        viewMember.memberId) {
                  return _createCollectionBar(context);
                }

                return Container();
              },
            );
          }

          if (index == controller.collectionList.length + 1) {
            return _loadMoreWidget();
          }

          return _buildListItem(context, controller.collectionList[index - 1]);
        },
        itemCount: controller.collectionList.length + 2,
      ),
    );
  }

  Widget _createCollectionBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 16, 15, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomColors>()?.primaryLv7,
        border: Border.all(
          color: Theme.of(context).extension<CustomColors>()!.primary200!,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AutoSizeText(
              'createCollectionBarTitle'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary500,
                fontSize: 16,
              ),
              maxLines: 1,
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const ChooseStoryPage()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'createCollectionBarButton'.tr,
                  style: TextStyle(
                    color: Theme.of(context).extension<CustomColors>()?.blue,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                ),
                Icon(
                  Icons.chevron_right_outlined,
                  color: Theme.of(context).extension<CustomColors>()?.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadMoreWidget() {
    if (controller.isNoMore.isTrue) {
      return Container();
    }

    return VisibilityDetector(
      key: Key('collectionTab${viewMember.memberId}'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 50 && controller.isLoadingMore.isFalse) {
          controller.fetchMoreCollection();
        }
      },
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Collection collection) {
    double width = context.width - 40;
    return Card(
      color: Theme.of(context).backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).extension<CustomColors>()!.primary200!,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Get.to(
                () => CollectionPage(collection),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Obx(
                      () => CachedNetworkImage(
                        imageUrl: Get.find<PickableItemController>(
                                    tag: collection.controllerTag)
                                .collectionHeroImageUrl
                                .value ??
                            collection.ogImageUrl,
                        placeholder: (context, url) => SizedBox(
                          width: width,
                          height: width / 2,
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .shimmerBaseColor!,
                            highlightColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary200!,
                            child: Container(
                              width: width,
                              height: width / 2,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(),
                        imageBuilder: (context, imageProvider) {
                          return Image(
                            image: imageProvider,
                            width: width,
                            height: width / 2,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: CollectionTag(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Obx(
                    () => ExtendedText(
                      Get.find<PickableItemController>(
                                  tag: collection.controllerTag)
                              .collectionTitle
                              .value ??
                          collection.title,
                      joinZeroWidthSpace: true,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primary700!,
                        fontSize: 16,
                        fontWeight: GetPlatform.isIOS
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                  child: CollectionInfo(collection, key: Key(collection.id)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: PickBar(collection.controllerTag),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
