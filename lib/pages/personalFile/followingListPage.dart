import 'dart:io';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: Platform.isIOS,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          viewMember.customId,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
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
              return _emptyWidget();
            }

            return _buildContent();
          }

          return const FollowSkeletonScreen();
        },
      ),
    );
  }

  Widget _emptyWidget() {
    bool isMine =
        Get.find<UserService>().currentUser.memberId == viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '目前沒有追蹤中的對象' : '這個人目前沒有追蹤中的對象',
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
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          '媒體  (${controller.followingPublisherList.length})',
                          style: TextStyle(
                            fontSize: 18,
                            color: readrBlack87,
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
                        color: readrBlack30,
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

              return _buildPublisherList();
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.followingMemberList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Obx(
                () => Text(
                  '人物  (${controller.followingMemberCount.value})',
                  style: TextStyle(
                    fontSize: 18,
                    color: readrBlack87,
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

              return _buildFollowingMemberList();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPublisherList() {
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
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.black12),
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

  Widget _buildFollowingMemberList() {
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
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.black12),
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
