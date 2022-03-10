import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    _followCount = widget.publisher.followerCount;
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
              Text(
                '${_followCount.toString()} 人追蹤',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
        FollowButton(
          PublisherFollowableItem(widget.publisher),
          onTap: (isFollow) {
            setState(() {
              if (isFollow) {
                _followCount++;
              } else {
                _followCount--;
              }
            });
          },
          whenFailed: (isFollow) {
            setState(() {
              if (isFollow) {
                _followCount++;
              } else {
                _followCount--;
              }
            });
          },
        ),
      ],
    );
  }
}
