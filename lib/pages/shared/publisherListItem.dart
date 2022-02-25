import 'package:flutter/material.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';

class PublisherListItem extends StatefulWidget {
  final Publisher publisher;
  const PublisherListItem({required this.publisher});

  @override
  _PublisherListItemState createState() => _PublisherListItemState();
}

class _PublisherListItemState extends State<PublisherListItem> {
  @override
  void initState() {
    super.initState();
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
                widget.publisher.followerCount?.toString() ?? '無' '人追蹤',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
        FollowButton(PublisherFollowableItem(widget.publisher)),
      ],
    );
  }
}
