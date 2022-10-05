import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/pages/shared/recommendFollow/lookmoreItem.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowItem.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowPage.dart';

class RecommendFollowBlock extends StatelessWidget {
  final RecommendItemController controller;
  final bool showTitleBar;
  const RecommendFollowBlock(this.controller, {this.showTitleBar = true});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.recommendItems.isEmpty) {
          return Container();
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            if (showTitleBar) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'recommendFollow'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => RecommendFollowPage(controller));
                      },
                      child: Text(
                        'viewAll'.tr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 240,
              child: Obx(
                () {
                  int itemLength = 5;
                  if (controller.recommendItems.length < 5) {
                    itemLength = controller.recommendItems.length;
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index == 4) {
                        return LookmoreItem(controller);
                      }

                      return RecommendFollowItem(
                          controller.recommendItems[index]);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemCount: itemLength,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
