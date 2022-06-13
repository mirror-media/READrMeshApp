import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/collection/createCollection/chooseStoryPage.dart';
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
            return _emptyWidget();
          }
          return _buildContent();
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    return Obx(
      () {
        if (Get.find<UserService>().isMember.isTrue &&
            Get.find<UserService>().currentUser.memberId ==
                viewMember.memberId) {
          return Container(
            color: homeScreenBackgroundColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '從精選新聞或書籤中\n將數篇新聞打包成集錦',
                    style: TextStyle(
                      color: readrBlack30,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () => Get.to(() => ChooseStoryPage()),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: readrBlack87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      '立即嘗試',
                      style: TextStyle(
                        color: Colors.white,
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
          color: homeScreenBackgroundColor,
          child: const Center(
            child: Text(
              '這個人還沒有建立集錦',
              style: TextStyle(
                color: readrBlack30,
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

  Widget _buildContent() {
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
                  return _createCollectionBar();
                }

                return Container();
              },
            );
          }

          if (index == controller.collectionList.length + 1) {
            return _loadMoreWidget();
          }

          return _buildListItem(controller.collectionList[index - 1]);
        },
        itemCount: controller.collectionList.length + 2,
      ),
    );
  }

  Widget _createCollectionBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 16, 15, 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 9, 40, 0.05),
        border: Border.all(
          color: readrBlack10,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '製作自己的新聞集錦',
            style: TextStyle(
              color: readrBlack50,
              fontSize: 16,
            ),
            maxLines: 1,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(() => ChooseStoryPage()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '立即建立',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                ),
                Icon(
                  Icons.chevron_right_outlined,
                  color: Colors.blue,
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

  Widget _buildListItem(Collection collection) {
    double width = Get.width - 40;
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                            baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                            highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                            child: Container(
                              width: width,
                              height: width / 2,
                              color: Colors.white,
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
                      style: const TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
