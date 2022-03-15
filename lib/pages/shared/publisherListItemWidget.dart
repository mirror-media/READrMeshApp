import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';

class PublisherListItemWidget extends StatefulWidget {
  final Publisher publisher;
  const PublisherListItemWidget({required this.publisher});

  @override
  _PublisherListItemWidgetState createState() =>
      _PublisherListItemWidgetState();
}

class _PublisherListItemWidgetState extends State<PublisherListItemWidget> {
  int _followCount = 0;
  late final bool _isFollowed;
  @override
  void initState() {
    super.initState();
    _followCount = widget.publisher.followerCount;
    _isFollowed = UserHelper.instance.isFollowingPublisher(widget.publisher);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PublisherLogoWidget(widget.publisher),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.publisher.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              BlocBuilder<FollowButtonCubit, FollowButtonState>(
                builder: (context, state) {
                  _updateFollowCount();
                  return Text(
                    '${_followCount.toString()} 人追蹤',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        FollowButton(
          PublisherFollowableItem(widget.publisher),
        ),
      ],
    );
  }

  void _updateFollowCount() {
    if (_isFollowed &&
        !UserHelper.instance.isLocalFollowingPublisher(widget.publisher)) {
      _followCount = widget.publisher.followerCount - 1;
    } else if (UserHelper.instance
        .isLocalFollowingPublisher(widget.publisher)) {
      _followCount = widget.publisher.followerCount + 1;
    } else {
      _followCount = widget.publisher.followerCount;
    }
  }
}
