import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/chooseMemberController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/services/recommendService.dart';

class ChooseMemberPage extends GetView<ChooseMemberController> {
  final bool isFromPublisher;
  const ChooseMemberPage(this.isFromPublisher);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: Platform.isIOS,
        elevation: 0,
        title: Text(
          'chooseMemberPageAppbarTitle'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
        ),
        leading: isFromPublisher
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.all(20),
              child: Text(
                'chooseMemberPageBodyText'.tr,
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary300!,
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
                  backgroundColor:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: Text(
                  'finish'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).backgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
