import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowItem.dart';

class RecommendFollowPage extends StatelessWidget {
  final RecommendItemController controller;
  const RecommendFollowPage(this.controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '推薦追蹤',
          style: TextStyle(
            color: readrBlack,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(
        () {
          double ratio = (context.width - 40 - 12) / 460;
          if (controller.recommendItems.isEmpty) {
            return const Center(
              child: Text(
                '暫無推薦追蹤',
                style: TextStyle(
                  color: readrBlack,
                  fontSize: 20,
                ),
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
