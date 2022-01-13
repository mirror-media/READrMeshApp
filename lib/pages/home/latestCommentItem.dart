import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/headShotWidget.dart';
import 'package:readr/services/memberService.dart';

class LatestCommentItem extends StatefulWidget {
  final NewsListItem news;
  final String myId;
  const LatestCommentItem(this.news, this.myId);

  @override
  _LatestCommentItemState createState() => _LatestCommentItemState();
}

class _LatestCommentItemState extends State<LatestCommentItem> {
  bool _isFollowed = false;
  final MemberService _memberService = MemberService();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width / (16 / 9),
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
          _commentsWidget(widget.news.otherComments),
        ],
      ),
    );
  }

  Widget _commentsWidget(List<Comment> comments) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20, bottom: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        bool hasEmail = false;
        if (comments[index].member.email != null &&
            comments[index].member.email!.contains('@')) {
          hasEmail = true;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadShotWidget(
              comments[index].member.nickname,
              44,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            comments[index].member.nickname,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (hasEmail)
                            Text(
                              '@${comments[index].member.email!.split('@')[0]}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          // check whether is login
                          if (FirebaseAuth.instance.currentUser != null) {
                            bool isSuccess = false;
                            if (!_isFollowed) {
                              isSuccess =
                                  await _memberService.addFollowingMember(
                                      widget.myId,
                                      comments[index].member.memberId);
                              Fluttertoast.showToast(
                                msg: isSuccess ? "新增追蹤成功" : "新增追蹤失敗，請稍後再試一次",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              isSuccess =
                                  await _memberService.removeFollowingMember(
                                      widget.myId,
                                      comments[index].member.memberId);
                              Fluttertoast.showToast(
                                msg: isSuccess ? "取消追蹤成功" : "取消追蹤失敗，請稍後再試一次",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                            if (isSuccess) {
                              _isFollowed = !_isFollowed;
                              setState(() {});
                            }
                          } else {
                            // if user is not login
                            Fluttertoast.showToast(
                              msg: "請先登入",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                        child: Card(
                          color: _isFollowed ? Colors.black87 : Colors.white,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.black87,
                              width: 1,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Text(
                            _isFollowed ? '追蹤中' : '追蹤',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  _isFollowed ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.5),
                  Text(
                    comments[index].content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
      itemCount: comments.length,
    );
  }
}
