import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class MemberListItem extends StatefulWidget {
  final Member viewMember;
  final Member currentMember;
  const MemberListItem({required this.viewMember, required this.currentMember});

  @override
  _MemberListItemState createState() => _MemberListItemState();
}

class _MemberListItemState extends State<MemberListItem> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.viewMember.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePhotoWidget(widget.viewMember, 22),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.viewMember.customId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.viewMember.nickname,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
        if (!(widget.viewMember.memberId == widget.currentMember.memberId))
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
        List<Member>? newFollowingList;
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          final MemberService _memberService = MemberService();

          if (!originFollowState) {
            newFollowingList = await _memberService.addFollowingMember(
                widget.currentMember.memberId, widget.viewMember.memberId);
          } else {
            newFollowingList = await _memberService.removeFollowingMember(
                widget.currentMember.memberId, widget.viewMember.memberId);
          }
        } else {
          final VisitorService _visitorService = VisitorService();

          if (!originFollowState) {
            newFollowingList = await _visitorService
                .addFollowingMember(widget.viewMember.memberId);
          } else {
            newFollowingList = await _visitorService
                .removeFollowingMember(widget.viewMember.memberId);
          }
        }
        if (newFollowingList == null) {
          setState(() {
            _isFollowing = !_isFollowing;
          });
        } else {
          widget.currentMember.following = newFollowingList;
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
