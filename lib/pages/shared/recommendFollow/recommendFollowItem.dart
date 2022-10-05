import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ExtendedText(
                  recommendItem.descriptionText,
                  joinZeroWidthSpace: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 12),
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
