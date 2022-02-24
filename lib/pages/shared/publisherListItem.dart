import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class PublisherListItem extends StatefulWidget {
  final Publisher publisher;
  final Member currentMember;
  const PublisherListItem(
      {required this.publisher, required this.currentMember});

  @override
  _PublisherListItemState createState() => _PublisherListItemState();
}

class _PublisherListItemState extends State<PublisherListItem> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentMember.followingPublisher != null) {
      _isFollowing = widget.currentMember.followingPublisher!
          .any((element) => element.id == widget.publisher.id);
    }
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
        _followButton(),
      ],
    );
  }

  Widget _followButton() {
    return OutlinedButton(
      onPressed: () async {
        bool originFollowState = _isFollowing;
        setState(() {
          _isFollowing = !_isFollowing;
        });
        List<Publisher>? newFollowingList;
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          final MemberService _memberService = MemberService();

          if (!originFollowState) {
            newFollowingList = await _memberService.addFollowPublisher(
                widget.currentMember.memberId, widget.publisher.id);
          } else {
            newFollowingList = await _memberService.removeFollowPublisher(
                widget.currentMember.memberId, widget.publisher.id);
          }
        } else {
          final VisitorService _visitorService = VisitorService();

          if (!originFollowState) {
            newFollowingList =
                await _visitorService.addFollowPublisher(widget.publisher.id);
          } else {
            newFollowingList = await _visitorService
                .removeFollowPublisher(widget.publisher.id);
          }
        }
        if (newFollowingList == null) {
          setState(() {
            _isFollowing = !_isFollowing;
          });
        } else {
          widget.currentMember.followingPublisher = newFollowingList;
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: _isFollowing ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
      child: Text(
        _isFollowing ? '追蹤中' : '追蹤',
        maxLines: 1,
        style: TextStyle(
          fontSize: 14,
          color: _isFollowing ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
