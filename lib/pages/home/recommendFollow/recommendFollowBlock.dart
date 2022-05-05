import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/home/recommendFollow/lookmoreItem.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowItem.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowPage.dart';

class RecommendFollowBlock extends StatelessWidget {
  final List<FollowableItem> recommendedItems;
  const RecommendFollowBlock(this.recommendedItems);

  @override
  Widget build(BuildContext context) {
    if (recommendedItems.isEmpty) {
      return Container();
    }

    if (Get.find<UserService>().currentUser.following.isEmpty &&
        recommendedItems.first.type == 'member') {
      return Container();
    }
    int itemLength = 5;
    if (recommendedItems.length < 5) {
      itemLength = recommendedItems.length;
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推薦追蹤',
                style: TextStyle(
                  fontSize: 18,
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => RecommendFollowPage(
                        recommendedItems,
                      ));
                },
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 14,
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 20),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == 4) {
                return LookmoreItem(recommendedItems);
              }

              if (index == itemLength) {
                return const SizedBox(width: 8);
              }

              return RecommendFollowItem(recommendedItems[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: itemLength,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
