import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/headShotWidget.dart';
import 'package:readr/services/memberService.dart';

class RecommendFollowItem extends StatefulWidget {
  final Member recommendMember;
  final String myId;
  const RecommendFollowItem(this.recommendMember, this.myId);

  @override
  _RecommendFollowItemState createState() => _RecommendFollowItemState();
}

class _RecommendFollowItemState extends State<RecommendFollowItem> {
  bool _isFollowed = false;
  final MemberService _memberService = MemberService();
  int _followerCount = 0;
  String _followerNickName = "";

  @override
  void initState() {
    super.initState();
    _followerCount = widget.recommendMember.followerCount ?? 0;
    if (widget.recommendMember.follower != null &&
        widget.recommendMember.follower!.isNotEmpty) {
      _followerNickName = widget.recommendMember.follower![0].nickname;
    }
  }

  @override
  Widget build(BuildContext context) {
    String contentText = '尚無人追蹤';
    if (_followerCount == 1) {
      contentText = '$_followerNickName的追蹤對象';
    } else if (_followerCount > 1) {
      contentText = '$_followerNickName 及其他 ${_followerCount - 1} 人的追蹤對象';
    }

    return GestureDetector(
      onTap: () {},
      child: Card(
        color: Colors.white,
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
              HeadShotWidget(widget.recommendMember.memberId, 64),
              const SizedBox(height: 12),
              Text(
                widget.recommendMember.nickname,
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
                  contentText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              _followButton(widget.recommendMember.memberId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _followButton(String targetId) {
    return GestureDetector(
      onTap: () async {
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          bool isSuccess = false;
          if (!_isFollowed) {
            isSuccess =
                await _memberService.addFollowingMember(widget.myId, targetId);
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
            isSuccess = await _memberService.removeFollowingMember(
                widget.myId, targetId);
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
            if (!_isFollowed && _followerCount == 0) {
              _followerNickName = '您';
            } else if (!_isFollowed) {
              _followerCount++;
            } else {
              _followerCount--;
            }
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
          AutoRouter.of(context).push(const LoginRoute());
        }
      },
      child: SizedBox(
        height: 40,
        child: Card(
          color: _isFollowed ? Colors.black87 : Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black87,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Text(
            _isFollowed ? '追蹤中' : '追蹤',
            style: TextStyle(
              fontSize: 14,
              color: _isFollowed ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
