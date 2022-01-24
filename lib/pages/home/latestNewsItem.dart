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
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/services/pickService.dart';

class LatestNewsItem extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  const LatestNewsItem(this.news, this.member);
  @override
  _LatestNewsItemState createState() => _LatestNewsItemState();
}

class _LatestNewsItemState extends State<LatestNewsItem> {
  bool _isPicked = false;
  final PickService _pickService = PickService();
  List<Member> _pickedMembers = [];
  int _pickCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.news.myPickId != null) {
      _isPicked = true;
    }
    _pickCount = widget.news.pickCount;
  }

  @override
  Widget build(BuildContext context) {
    _pickedMembers = [];
    if (_isPicked) {
      _pickedMembers.add(widget.member);
    }
    _pickedMembers.addAll(widget.news.followingPickMembers);
    _pickedMembers.addAll(widget.news.otherPickMembers);
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
        _pickButton(context, widget.news),
      ];
    } else {
      bottom = [
        ProfilePhotoStack(_pickedMembers, 14),
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
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
        _pickButton(context, widget.news),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            Expanded(
              child: Text(
                widget.news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: CachedNetworkImage(
                width: 96,
                height: 96 / 2,
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
    );
  }

  Widget _pickButton(BuildContext context, NewsListItem news) {
    return OutlinedButton(
      onPressed: _isLoading
          ? null
          : () async {
              // check whether is login
              if (FirebaseAuth.instance.currentUser != null) {
                if (!_isPicked) {
                  var result = await PickBottomSheet.showPickBottomSheet(
                    context: context,
                    member: widget.member,
                  );

                  String? pickId;

                  if (result is bool && result) {
                    // refresh UI first
                    setState(() {
                      news.myPickId = 'loading';
                      _pickCount++;
                      _isPicked = !_isPicked;
                      // freeze onPressed when waiting for response
                      _isLoading = true;
                    });
                    //send request to api. If content is null, only pick
                    pickId = await _pickService.createPick(
                      memberId: widget.member.memberId,
                      targetId: news.id,
                      objective: PickObjective.story,
                      state: PickState.public,
                      kind: PickKind.read,
                    );
                  } else if (result is String) {
                    // refresh UI first
                    setState(() {
                      news.myPickId = 'loading';
                      _pickCount++;
                      _isPicked = !_isPicked;
                      // freeze onPressed when waiting for response
                      _isLoading = true;
                    });
                    //send request to api. If content is null, only pick
                    var pickAndComment =
                        await _pickService.createPickAndComment(
                      memberId: widget.member.memberId,
                      targetId: news.id,
                      objective: PickObjective.story,
                      state: PickState.public,
                      kind: PickKind.read,
                      commentContent: result,
                    );
                    pickId = pickAndComment?['pickId'];
                  }

                  if ((result is bool && result) || (result is String)) {
                    // If pickId is null, mean failed
                    PickToast.showPickToast(context, pickId != null, true);
                    if (pickId != null) {
                      // update new myPickId to real id
                      news.myPickId = pickId;
                    } else {
                      // recovery UI when is failed
                      news.myPickId = null;
                      setState(() {
                        _pickCount--;
                        _isPicked = !_isPicked;
                      });
                    }
                    // Let onPressed function can be called
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  // save myPickId to recovery when is failed
                  String myPickId = news.myPickId!;

                  // refresh UI first
                  setState(() {
                    news.myPickId = null;
                    _pickCount--;
                    _isPicked = !_isPicked;
                    // freeze onPressed when waiting for response
                    _isLoading = true;
                  });

                  // send request to api
                  bool isSuccess = await _pickService.deletePick(myPickId);

                  // show toast by result
                  PickToast.showPickToast(context, isSuccess, false);

                  // when failed, recovery UI and news' myPickId
                  if (!isSuccess) {
                    setState(() {
                      news.myPickId = myPickId;
                      _pickCount++;
                      _isPicked = !_isPicked;
                    });
                  }
                  // Let onPressed function can be called
                  setState(() {
                    _isLoading = false;
                  });
                }
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
        backgroundColor: _isPicked ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.fromLTRB(11, 3, 12, 4),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                _isPicked ? Icons.done_outlined : Icons.add_outlined,
                size: 18,
                color: _isPicked ? Colors.white : Colors.black87,
              ),
            ),
            TextSpan(
              text: _isPicked ? '已精選' : '精選',
              style: TextStyle(
                fontSize: 14,
                height: 1.9,
                color: _isPicked ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
