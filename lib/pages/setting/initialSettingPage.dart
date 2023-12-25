import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/themes.dart';

class InitialSettingPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'initialSettingPageTitle'.tr,
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
      body: SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _buildItem(context, index),
            separatorBuilder: (context, index) => const Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            itemCount: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    String title = 'communityTab'.tr;
    if (index == 1) {
      title = 'latestTab'.tr;
    }
    return GestureDetector(
      onTap: () => controller.initialPageIndex.value = index,
      child: Container(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primary700!,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            Obx(
              () {
                if (controller.initialPageIndex.value == index) {
                  return Icon(
                    Icons.check_outlined,
                    color: Theme.of(context).extension<CustomColors>()!.blue!,
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
