import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/shared/follow/followButton.dart';

class RecommendFollowItem extends StatelessWidget {
  final FollowableItem recommendItem;
  const RecommendFollowItem(this.recommendItem);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        recommendItem.onTap();
      },
      child: Card(
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
              recommendItem.defaultProfilePhotoWidget(),
              const SizedBox(height: 12),
              const Spacer(),
              ExtendedText(
                recommendItem.name,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ExtendedText(
                  recommendItem.descriptionText,
                  joinZeroWidthSpace: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 10),
              FollowButton(
                recommendItem,
                expanded: true,
                textSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
