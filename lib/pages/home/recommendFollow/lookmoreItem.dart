import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/followableItem.dart';

class LookmoreItem extends StatelessWidget {
  final List<FollowableItem> recommendedItems;
  const LookmoreItem(this.recommendedItems);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
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
              child: Text(
                recommendedItems[0].lookmoreText,
                style: const TextStyle(
                  fontSize: 12,
                  color: readrBlack50,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  AutoRouter.of(context).push(RecommendFollowRoute(
                    recommendedItems: recommendedItems,
                  ));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: readrBlack87, width: 1),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  '查看全部',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    color: readrBlack87,
                  ),
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
    for (int i = 4; i < 7 && i < recommendedItems.length; i++) {
      items.add(recommendedItems[i]);
    }
    if (items.length == 1) {
      return items[0].defaultProfilePhotoWidget(context);
    } else if (items.length == 2) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.topRight,
            child: items[0].profilePhotoWidget(context),
          ),
          Container(
            padding: const EdgeInsets.only(left: 24),
            alignment: Alignment.bottomLeft,
            child: items[1].profilePhotoWidget(context),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 29),
            alignment: Alignment.topLeft,
            child: items[0].profilePhotoWidget(context),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 8, right: 18),
            alignment: Alignment.bottomRight,
            child: items[1].profilePhotoWidget(context),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.bottomLeft,
            child: items[2].profilePhotoWidget(context),
          ),
        ],
      );
    }
  }
}
