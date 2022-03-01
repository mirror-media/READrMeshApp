import 'package:flutter/material.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendFollowItem extends StatefulWidget {
  final FollowableItem recommendItem;
  const RecommendFollowItem(this.recommendItem);

  @override
  _RecommendFollowItemState createState() => _RecommendFollowItemState();
}

class _RecommendFollowItemState extends State<RecommendFollowItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.recommendItem.onTap(context);
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
              widget.recommendItem.defaultProfilePhotoWidget(context),
              const SizedBox(height: 12),
              Text(
                widget.recommendItem.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 34,
                child: Text(
                  widget.recommendItem.descriptionText,
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
                widget.recommendItem,
                expanded: true,
                textSize: 16,
                onTap: (bool isFollowing) {
                  widget.recommendItem.updateHomeScreen(context, isFollowing);
                  setState(() {
                    widget.recommendItem.isFollowed =
                        !widget.recommendItem.isFollowed;
                  });
                },
                whenFailed: (bool isFollowing) {
                  widget.recommendItem.updateHomeScreen(context, isFollowing);
                  setState(() {
                    widget.recommendItem.isFollowed =
                        !widget.recommendItem.isFollowed;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
