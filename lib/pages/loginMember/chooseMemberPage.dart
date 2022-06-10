import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/chooseMemberController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/follow/followingSyncToast.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/services/recommendService.dart';

class ChooseMemberPage extends GetView<ChooseMemberController> {
  final bool isFromPublisher;
  const ChooseMemberPage(this.isFromPublisher);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS,
        elevation: 0,
        title: const Text(
          '推薦追蹤',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        leading: isFromPublisher
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: readrBlack87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: const Text(
              '根據您的喜好，我們推薦您追蹤這些人物',
              style: TextStyle(
                color: readrBlack87,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<ChooseMemberController>(
              init: ChooseMemberController(RecommendService()),
              builder: (controller) {
                if (controller.isError) {
                  return ErrorPage(
                    error: controller.error,
                    onPressed: () => controller.fetchRecommendMember(),
                    hideAppbar: true,
                  );
                }

                if (!controller.isLoading) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemBuilder: (context, index) => MemberListItemWidget(
                      viewMember: controller.recommendedMembers[index],
                    ),
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(
                        color: readrBlack10,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    itemCount: controller.recommendedMembers.length,
                  );
                }

                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 17),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: readrBlack20,
                  width: 0.5,
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final prefs = Get.find<SharedPreferencesService>().prefs;
                final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
                if (isFirstTime) {
                  Get.offAll(RootPage());
                  await prefs.setBool('isFirstTime', false);
                } else {
                  Get.until((route) => Get.currentRoute == '/LoginPage');
                  Get.back();
                  if (!isFromPublisher) {
                    showFollowingSyncToast();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: readrBlack87,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              child: const Text(
                '完成',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
