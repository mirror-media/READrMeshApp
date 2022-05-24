import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/dataConstants.dart';

class NewsCoverageSettingPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '顯示新聞範圍',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildItem(context, index),
          separatorBuilder: (context, index) => const Divider(
            color: readrBlack10,
            height: 0.5,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          itemCount: 3,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    String title = '24小時內';
    if (index == 1) {
      title = '3天內';
    } else if (index == 2) {
      title = '1週內';
    }
    return GestureDetector(
      onTap: () => controller.updateDuration(index),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            Obx(
              () {
                if (controller.durationCheckIndex.value == index) {
                  return const Icon(
                    Icons.check_outlined,
                    color: Colors.blue,
                    size: 16,
                  );
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
