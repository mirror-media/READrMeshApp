import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/collection/smallCollectionItem.dart';
import 'package:readr/pages/personalFile/pickCommentItem.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';
import 'package:readr/services/commentService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PickTabContent extends GetView<PickTabController> {
  final Member viewMember;
  const PickTabContent({
    required this.viewMember,
  });

  @override
  String get tag => viewMember.memberId;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<PickTabController>(tag: viewMember.memberId)) {
      controller.fetchPickList();
    } else {
      Get.put(
        PickTabController(
          PersonalFileService(),
          CommentService(),
          viewMember,
        ),
        tag: viewMember.memberId,
      );
    }
    return GetBuilder<PickTabController>(
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
          if (controller.storyPickList.isEmpty &&
              controller.collecionPickList.isEmpty) {
            return _emptyWidget();
          }

          return Obx(() {
            if (Get.find<PersonalFilePageController>(tag: viewMember.memberId)
                .isBlock
                .isTrue) {
              return _emptyWidget();
            }

            return _buildContent();
          });
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    bool isMine =
        Get.find<UserService>().currentUser.memberId == viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '這裡還空空的\n趕緊將喜愛的新聞加入精選吧' : '這個人還沒有精選新聞',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: readrBlack30,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      children: [
        Obx(
          () {
            if (controller.collecionPickList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Text(
                '精選集錦',
                style: TextStyle(
                  color: readrBlack87,
                  fontSize: 18,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            );
          },
        ),
        _buildPickCollectionList(),
        Obx(
          () {
            if (controller.storyPickList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Text(
                '精選文章',
                style: TextStyle(
                  color: readrBlack87,
                  fontSize: 18,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            );
          },
        ),
        _buildPickStoryList(),
      ],
    );
  }

  Widget _buildPickStoryList() {
    return Obx(
      () => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          if (index == controller.storyPickList.length) {
            if (controller.noMoreStoryPick.isTrue) {
              return Container();
            }

            return VisibilityDetector(
              key: Key('pickTab${viewMember.memberId}'),
              onVisibilityChanged: (visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 50 &&
                    controller.isLoadingMoreStoryPick.isFalse) {
                  controller.fetchMoreStoryPick();
                }
              },
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          var pick = controller.storyPickList[index];

          if (pick.pickComment != null) {
            return Column(
              children: [
                NewsListItemWidget(
                  pick.story!,
                  isInMyPersonalFile: viewMember.memberId ==
                      Get.find<UserService>().currentUser.memberId,
                  showPickTooltip:
                      index == 0 && controller.collecionPickList.isEmpty,
                ),
                const SizedBox(
                  height: 12,
                ),
                PickCommentItem(
                  comment: pick.pickComment!,
                  pickControllerTag: pick.story!.controllerTag,
                  key: Key(pick.pickComment!.id),
                ),
              ],
            );
          }
          return NewsListItemWidget(
            pick.story!,
            isInMyPersonalFile: viewMember.memberId ==
                Get.find<UserService>().currentUser.memberId,
            showPickTooltip: index == 0 && controller.collecionPickList.isEmpty,
            key: Key(pick.story!.id),
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.storyPickList.length - 1) {
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
        itemCount: controller.storyPickList.length + 1,
      ),
    );
  }

  Widget _buildPickCollectionList() {
    return Obx(
      () {
        if (controller.collecionPickList.isEmpty) {
          return Container();
        }

        return SizedBox(
          height: 290,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemBuilder: (context, index) {
              if (index == controller.collecionPickList.length) {
                if (controller.noMoreCollectionPick.isTrue) {
                  return Container();
                }

                return VisibilityDetector(
                  key: Key('pickTabCollecion${viewMember.memberId}'),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage > 50 &&
                        controller.isLoadingMoreCollectionPick.isFalse) {
                      controller.fetchMoreCollectionPick();
                    }
                  },
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              return SmallCollectionItem(
                controller.collecionPickList[index].collection!,
                showPickTooltip: index == 0,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: controller.collecionPickList.length + 1,
          ),
        );
      },
    );
  }
}
