import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/loginMember/chooseMemberPage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/publisherListItemWidget.dart';
import 'package:readr/services/recommendService.dart';

class ChoosePublisherPage extends GetView<ChoosePublisherController> {
  @override
  Widget build(BuildContext context) {
    Get.put<ChoosePublisherController>(
        ChoosePublisherController(RecommendService()));
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'choosePublisherPageAppbarTitle'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(context) {
    String buttonText;
    if (Get.find<UserService>().isMember.isFalse) {
      buttonText = 'finish'.tr;
    } else {
      buttonText = 'nextStep'.tr;
    }
    Color disableColor = Theme.of(context).brightness == Brightness.light
        ? meshBlack20
        : const Color.fromRGBO(203, 203, 203, 1);
    return Column(
      children: [
        Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.all(20),
          child: Text(
            'choosePublisherPageBodyText'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: _buildContent(context),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv5!,
                width: 0.5,
              ),
            ),
          ),
          child: Obx(
            () => OutlinedButton(
              onPressed: controller.followedCount.value == 0
                  ? null
                  : () async {
                      if (Get.find<UserService>().isMember.isTrue) {
                        Get.to(() => const ChooseMemberPage(true));
                      } else {
                        final prefs =
                            Get.find<SharedPreferencesService>().prefs;
                        Get.offAll(RootPage());
                        await prefs.setBool('isFirstTime', false);
                      }
                    },
              style: OutlinedButton.styleFrom(
                elevation: 0,
                backgroundColor: controller.followedCount.value == 0
                    ? disableColor
                    : Theme.of(context).extension<CustomColors>()!.primary700!,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              child: Text(
                controller.followedCount.value == 0
                    ? 'noChoosePublisherButtonText'.tr
                    : buttonText,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.followedCount.value == 0
                      ? meshBlack20
                      : Theme.of(context).backgroundColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return GetBuilder<ChoosePublisherController>(
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchAllPublishers(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          return _buildList(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemBuilder: (context, index) =>
          PublisherListItemWidget(publisher: controller.publishers[index]),
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(
          thickness: 1,
          height: 1,
        ),
      ),
      itemCount: controller.publishers.length,
    );
  }
}
