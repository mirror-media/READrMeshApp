import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendFollowItem extends StatelessWidget {
  final FollowableItem recommendItem;
  const RecommendFollowItem(this.recommendItem);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        recommendItem.onTap(context);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              recommendItem.defaultProfilePhotoWidget(context),
              const SizedBox(height: 12),
              ExtendedText(
                recommendItem.name,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 34,
                child: ExtendedText(
                  recommendItem.descriptionText,
                  joinZeroWidthSpace: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              FollowButton(
                recommendItem,
                expanded: true,
                textSize: 16,
                onTap: (bool isFollowing) =>
                    context.read<HomeBloc>().add(RefreshHomeScreen()),
                whenFailed: (bool isFollowing) =>
                    context.read<HomeBloc>().add(RefreshHomeScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
