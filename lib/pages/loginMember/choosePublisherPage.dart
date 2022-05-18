import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/initialApp.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/loginMember/chooseMember/chooseMemberPage.dart';
import 'package:readr/pages/shared/publisherListItemWidget.dart';
import 'package:readr/services/recommendService.dart';

class ChoosePublisherPage extends GetView<ChoosePublisherController> {
  @override
  Widget build(BuildContext context) {
    Get.put<ChoosePublisherController>(
        ChoosePublisherController(RecommendService()));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          '歡迎使用',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
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
    if (Get.find<UserService>().isVisitor) {
      buttonText = '完成';
    } else {
      buttonText = '下一步';
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const Text(
            '請選擇您想追蹤的媒體',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: _buildContent(context),
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
          child: Obx(
            () => OutlinedButton(
              onPressed: controller.followedCount.value == 0
                  ? null
                  : () async {
                      if (Get.find<UserService>().isMember) {
                        Get.to(() => const ChooseMemberPage(true));
                      } else {
                        final prefs =
                            Get.find<SharedPreferencesService>().prefs;
                        await prefs.setBool('isFirstTime', false);
                        Get.offAll(() => InitialApp());
                      }
                    },
              style: OutlinedButton.styleFrom(
                elevation: 0,
                backgroundColor: controller.followedCount.value == 0
                    ? const Color.fromRGBO(224, 224, 224, 1)
                    : readrBlack87,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              child: Text(
                controller.followedCount.value == 0 ? '請至少選擇 1 個' : buttonText,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.followedCount.value == 0
                      ? readrBlack20
                      : Colors.white,
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
          color: readrBlack10,
          thickness: 1,
          height: 1,
        ),
      ),
      itemCount: controller.publishers.length,
    );
  }
}
