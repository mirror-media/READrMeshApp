import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/headShotStack.dart';
import 'package:readr/services/memberService.dart';

class LatestNewsItem extends StatefulWidget {
  final NewsListItem news;
  final String myId;
  const LatestNewsItem(this.news, this.myId);
  @override
  _LatestNewsItemState createState() => _LatestNewsItemState();
}

class _LatestNewsItemState extends State<LatestNewsItem> {
  bool _isPicked = false;
  final MemberService _memberService = MemberService();
  List<Member> _pickedMembers = [];
  int _pickCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.news.myPickId != null) {
      _isPicked = true;
    }
    _pickedMembers = widget.news.followingPickMembers;
    _pickedMembers.addAll(widget.news.otherPickMembers);
    _pickCount = widget.news.pickCount;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottom = [];
    if (_pickCount == 0) {
      bottom = [
        const Text(
          '尚無人精選',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Expanded(
          child: Container(),
        ),
        _pickButton(widget.news),
      ];
    } else {
      bottom = [
        HeadShotStack(_pickedMembers, 28),
        const SizedBox(width: 8),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: _pickCount.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' 人精選',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
        _pickButton(widget.news),
      ];
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (widget.news.source != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.news.source!.title,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  width: 96,
                  height: 96 / (16 / 9),
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
              ),
              const SizedBox(width: 12),
              Text(
                widget.news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NewsInfo(widget.news),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: bottom,
          )
        ],
      ),
    );
  }

  Widget _pickButton(NewsListItem news) {
    return GestureDetector(
      onTap: () async {
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          bool isSuccess = false;
          if (!_isPicked) {
            String? pickId = await _memberService.addPick(
              memberId: widget.myId,
              targetId: news.id,
              objective: PickObjective.story,
              state: PickState.public,
              kind: PickKind.read,
            );
            if (pickId != null) {
              isSuccess = true;
              news.myPickId = pickId;
            }
            Fluttertoast.showToast(
              msg: isSuccess ? "精選成功" : "精選失敗，請稍後再試一次",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            isSuccess = await _memberService.deletePick(news.myPickId!);
            Fluttertoast.showToast(
              msg: isSuccess ? "取消精選成功" : "取消精選失敗，請稍後再試一次",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            if (isSuccess) {
              news.myPickId = null;
            }
          }
          if (isSuccess) {
            _isPicked = !_isPicked;
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
        width: 68,
        child: Card(
          color: _isPicked ? Colors.black87 : Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black87,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPicked ? Icons.done_outlined : Icons.add_outlined,
                size: 18,
                color: _isPicked ? Colors.white : Colors.black87,
              ),
              Text(
                _isPicked ? '已精選' : '精選',
                style: TextStyle(
                  fontSize: 14,
                  color: _isPicked ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
