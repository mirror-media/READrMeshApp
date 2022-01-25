import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheet.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LatestCommentItem extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  const LatestCommentItem(this.news, this.member);

  @override
  _LatestCommentItemState createState() => _LatestCommentItemState();
}

class _LatestCommentItemState extends State<LatestCommentItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width / 2,
            imageUrl: widget.news.heroImageUrl,
            placeholder: (context, url) => Container(
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          if (widget.news.source != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Text(
                widget.news.source!.title,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 12, right: 12, bottom: 8),
            child: Text(
              widget.news.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
            child: NewsInfo(widget.news),
          ),
          const Divider(
            indent: 12,
            endIndent: 12,
            color: Colors.black12,
            height: 1,
            thickness: 1,
          ),
          InkWell(
            onTap: () async {
              await CommentBottomSheet.showCommentBottomSheet(
                context: context,
                member: widget.member,
                clickComment: widget.news.showComment!,
                storyId: widget.news.id,
              );
            },
            child: _commentsWidget(widget.news.showComment!),
          ),
        ],
      ),
    );
  }

  Widget _commentsWidget(Comment comment) {
    bool hasEmail = false;
    if (comment.member.email != null && comment.member.email!.contains('@')) {
      hasEmail = true;
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePhotoWidget(
                comment.member,
                22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.member.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasEmail)
                      Text(
                        '@${comment.member.email!.split('@')[0]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              _followButton(comment),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8.5, bottom: 20),
            child: ExtendedText(
              comment.content,
              maxLines: 2,
              style: const TextStyle(
                color: Color.fromRGBO(0, 9, 40, 0.66),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              joinZeroWidthSpace: true,
              overflowWidget: TextOverflowWidget(
                position: TextOverflowPosition.end,
                child: RichText(
                  text: const TextSpan(
                    text: '... ',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 9, 40, 0.66),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: '看完整留言',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _followButton(Comment comment) {
    bool isFollowed = false;
    if (widget.member.following != null) {
      int index = widget.member.following!
          .indexWhere((member) => member.memberId == comment.member.memberId);
      if (index != -1) {
        isFollowed = true;
      }
    }

    return OutlinedButton(
      onPressed: () {
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          context.read<HomeBloc>().add(
              UpdateFollowingMember(comment.member, widget.member, isFollowed));
        } else {
          // if user is not login
          Fluttertoast.showToast(
            msg: "請先登入",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
          AutoRouter.of(context).push(const LoginRoute());
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: isFollowed ? Colors.black87 : Colors.white,
      ),
      child: Text(
        isFollowed ? '追蹤中' : '追蹤',
        style: TextStyle(
          fontSize: 14,
          color: isFollowed ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
