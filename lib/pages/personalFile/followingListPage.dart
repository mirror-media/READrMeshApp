import 'dart:io';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/followSkeletonScreen.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/pages/shared/publisherListItemWidget.dart';
import 'package:readr/services/personalFileService.dart';

class FollowingListPage extends GetView<FollowingListController> {
  final Member viewMember;
  const FollowingListPage({required this.viewMember});

  @override
  String get tag => viewMember.memberId;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<FollowingListController>(tag: viewMember.memberId)) {
      controller.fetchFollowingList();
    } else {
      Get.put(
        FollowingListController(
          personalFileRepos: PersonalFileService(),
          viewMember: viewMember,
        ),
        tag: viewMember.memberId,
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: Platform.isIOS,
        title: Text(
          viewMember.customId,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<FollowingListController>(
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
            if (controller.followingMemberList.isEmpty &&
                controller.followingPublisherList.isEmpty) {
              return _emptyWidget(context);
            }

            return _buildContent(context);
          }

          return const FollowSkeletonScreen();
        },
      ),
    );
  }

  Widget _emptyWidget(BuildContext context) {
    bool isMine =
        Get.find<UserService>().currentUser.memberId == viewMember.memberId;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Text(
          isMine ? 'noFollowing'.tr : 'viewMemberNoFollowing'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv4!,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.followingPublisherList.isEmpty) {
              return Container();
            }

            return GestureDetector(
              onTap: () {
                controller.isExpanded.toggle();
              },
              child: Container(
                color: Theme.of(context).backgroundColor,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          '${'media'.tr}  (${controller.followingPublisherList.length})',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary700!,
                            fontWeight: GetPlatform.isIOS
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Icon(
                        controller.isExpanded.value
                            ? Icons.expand_less_outlined
                            : Icons.expand_more_outlined,
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv4!,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        SliverToBoxAdapter(
          child: Obx(
            () {
              if (controller.isExpanded.isFalse ||
                  controller.followingPublisherList.isEmpty) {
                return Container();
              }

              return _buildPublisherList(context);
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.followingMemberList.isEmpty) {
              return Container();
            }

            return Container(
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Obx(
                () => Text(
                  '${'figure'.tr}  (${controller.followingMemberCount.value})',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary700!,
                    fontWeight:
                        GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        SliverToBoxAdapter(
          child: Obx(
            () {
              if (controller.followingMemberList.isEmpty) {
                return Container();
              }

              return _buildFollowingMemberList(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPublisherList(BuildContext context) {
    return ImplicitlyAnimatedList<Publisher>(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      items: controller.followingPublisherList,
      areItemsTheSame: (a, b) => a.id == b.id,
      itemBuilder: (context, animation, item, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: Container(
            key: Key(item.id + index.toString()),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv6!,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(() => PublisherPage(item));
              },
              child: PublisherListItemWidget(publisher: item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowingMemberList(BuildContext context) {
    return ImplicitlyAnimatedList<Member>(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      items: controller.followingMemberList,
      areItemsTheSame: (a, b) => a.memberId == b.memberId,
      itemBuilder: (context, animation, item, index) {
        if (index == controller.followingMemberList.length - 2 &&
            controller.isNoMore.isFalse &&
            controller.isLoadingMore.isFalse) {
          controller.fetchMoreFollowingMember();
        }
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: Container(
            key: Key(item.memberId + index.toString()),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv6!,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(() => PersonalFilePage(viewMember: item));
              },
              child: MemberListItemWidget(viewMember: item),
            ),
          ),
        );
      },
    );
  }
}
