import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/followSkeletonScreen.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/pages/shared/publisherListItemWidget.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
        if (controller.followingPublisherList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                controller.isExpanded.toggle();
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '媒體  (${controller.followingPublisherList.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          color: readrBlack87,
                          fontWeight: FontWeight.w500,
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
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () {
                if (controller.isExpanded.isFalse) {
                  return Container();
                }

                return _buildPublisherList();
              },
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.followingMemberList.isEmpty) {
              return Container();
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Text(
                '人物  (${controller.followingMemberCount})',
                style: const TextStyle(
                  fontSize: 18,
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == controller.followingPublisherList.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        }
        return InkWell(
          onTap: () {
            Get.to(() => PublisherPage(
                  controller.followingPublisherList[index],
                ));
          },
          child: PublisherListItemWidget(
            publisher: controller.followingPublisherList[index],
          ),
        );
      },
      separatorBuilder: (context, index) {
        if (index == controller.followingPublisherList.length - 1) {
          return Container();
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            color: readrBlack10,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: controller.followingPublisherList.length + 1,
    );
  }

  Widget _buildFollowingMemberList() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == controller.followingMemberList.length) {
            if (controller.isNoMore.isTrue) {
              return Container();
            }

            return VisibilityDetector(
              key: ValueKey('followerList${viewMember.memberId}'),
              onVisibilityChanged: (VisibilityInfo info) {
                var visiblePercentage = info.visibleFraction * 100;
                if (visiblePercentage > 50 &&
                    controller.isLoadingMore.isFalse) {
                  controller.fetchMoreFollowingMember();
                }
              },
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          return InkWell(
            onTap: () {
              Get.to(() => PersonalFilePage(
                    viewMember: controller.followingMemberList[index],
                  ));
            },
            child: MemberListItemWidget(
              viewMember: controller.followingMemberList[index],
            ),
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.followingMemberList.length - 1) {
            return const SizedBox(
              height: 36,
            );
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: controller.followingMemberList.length + 1,
      ),
    );
  }
}
