import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowPage.dart';

class LookmoreItem extends StatelessWidget {
  final RecommendItemController controller;
  const LookmoreItem(this.controller);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        width: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 89,
              child: _moreProfilePhotoStack(context),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ExtendedText(
                controller.recommendItems.first.lookmoreText,
                joinZeroWidthSpace: true,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 12),
                maxLines: 2,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Get.to(() => RecommendFollowPage(controller));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Theme.of(context).primaryColorDark, width: 1),
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  'viewAll'.tr,
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreProfilePhotoStack(BuildContext context) {
    List<FollowableItem> items = [];
    for (int i = 4; i < 7 && i < controller.recommendItems.length; i++) {
      items.add(controller.recommendItems[i]);
    }
    if (items.length == 1) {
      return items[0].defaultProfilePhotoWidget();
    } else if (items.length == 2) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.topRight,
            child: items[0].profilePhotoWidget(),
          ),
          Container(
            padding: const EdgeInsets.only(left: 24),
            alignment: Alignment.bottomLeft,
            child: items[1].profilePhotoWidget(),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 29),
            alignment: Alignment.topLeft,
            child: items[0].profilePhotoWidget(),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 8, right: 18),
            alignment: Alignment.bottomRight,
            child: items[1].profilePhotoWidget(),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.bottomLeft,
            child: items[2].profilePhotoWidget(),
          ),
        ],
      );
    }
  }
}
