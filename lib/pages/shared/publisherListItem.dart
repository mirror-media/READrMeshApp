import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
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
        _logoImage(),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.publisher.customId != null)
                Text(
                  widget.publisher.customId!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              Text(
                widget.publisher.title,
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

  Widget _logoImage() {
    Color randomColor = Colors
        .primaries[int.parse(widget.publisher.id) % Colors.primaries.length];
    Color textColor =
        randomColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    List<String> splitTitle = widget.publisher.title.split('');
    String firstLetter = '';
    for (int i = 0; i < splitTitle.length; i++) {
      if (splitTitle[i] != " ") {
        firstLetter = splitTitle[i];
        break;
      }
    }
    Widget child;
    Widget background;
    if (widget.publisher.logoUrl == null || widget.publisher.logoUrl! == '') {
      child = Container(
        alignment: Alignment.center,
        color: randomColor,
        child: AutoSizeText(
          firstLetter,
          style: TextStyle(color: textColor),
          minFontSize: 5,
        ),
      );
    } else {
      background = Container(
        color: randomColor,
        child: AutoSizeText(
          firstLetter,
          style: TextStyle(color: textColor),
          minFontSize: 5,
        ),
      );
      child = CachedNetworkImage(
        imageUrl: widget.publisher.logoUrl!,
        placeholder: (context, url) => Container(
          color: Colors.grey,
        ),
        errorWidget: (context, url, error) => background,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Colors.black12,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
