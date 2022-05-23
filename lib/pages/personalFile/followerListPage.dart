import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/followerListController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/followSkeletonScreen.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FollowerListPage extends GetView<FollowerListController> {
  final Member viewMember;
  const FollowerListPage({required this.viewMember});

  @override
  String get tag => viewMember.memberId;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<FollowerListController>(tag: viewMember.memberId)) {
      controller.fetchFollowerList();
    } else {
      Get.put(
        FollowerListController(
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
      body: GetBuilder<FollowerListController>(
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
            if (controller.followerList.isEmpty) {
              return _emptyWidget();
            }
            return _buildBody();
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
          isMine ? '目前還沒有粉絲' : '這個人還沒有粉絲',
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

  Widget _buildBody() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemBuilder: (context, index) {
          if (index == controller.followerList.length) {
            if (controller.isNoMore.isTrue) {
              return Container();
            }

            return VisibilityDetector(
              key: ValueKey('followerList${viewMember.memberId}'),
              onVisibilityChanged: (VisibilityInfo info) {
                var visiblePercentage = info.visibleFraction * 100;
                if (visiblePercentage > 50 &&
                    controller.isLoadingMore.isFalse) {
                  controller.fetchMoreFollower();
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
                    viewMember: controller.followerList[index],
                  ));
            },
            child: MemberListItemWidget(
              viewMember: controller.followerList[index],
            ),
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.followerList.length - 1) {
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
        itemCount: controller.followerList.length + 1,
      ),
    );
  }
}
