import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowItem.dart';

class RecommendFollowPage extends StatelessWidget {
  final RecommendItemController controller;
  const RecommendFollowPage(this.controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'recommendFollow'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 18),
        ),
      ),
      body: Obx(
        () {
          double ratio = (context.width - 40 - 12) / 460;
          if (controller.recommendItems.isEmpty) {
            return Center(
              child: Text(
                'noRecommend'.tr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) =>
                RecommendFollowItem(controller.recommendItems[index]),
            itemCount: controller.recommendItems.length,
          );
        },
      ),
    );
  }
}
