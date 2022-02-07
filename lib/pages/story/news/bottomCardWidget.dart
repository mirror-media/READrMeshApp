import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/services/commentService.dart';
import 'package:readr/services/pickService.dart';

class BottomCardWidget extends StatefulWidget {
  final NewsStoryItem news;
  final Member member;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<bool> isPickedButton;
  final bool isPicked;

  const BottomCardWidget({
    required this.news,
    required this.member,
    required this.onTextChanged,
    required this.isPickedButton,
    this.isPicked = false,
  });

  @override
  _BottomCardWidgetState createState() => _BottomCardWidgetState();
}

class _BottomCardWidgetState extends State<BottomCardWidget> {
  bool _isPicked = false;
  bool _isLoading = false;
  int _pickCount = 0;
  final PickService _pickService = PickService();
  final CommentService _commentService = CommentService();
  bool _isSending = false;
  final TextEditingController _textController = TextEditingController();
  List<Comment> _allComments = [];
  List<Member> _pickAvatarMembers = [];
  bool _hasMyNewComment = false;
  late Comment _myNewComment;
  bool _isCollapsed = true;

  @override
  void initState() {
    super.initState();
    _isPicked = widget.isPicked;
    _pickCount = widget.news.pickCount;
    _allComments = widget.news.allComments;
    _pickAvatarMembers = widget.news.followingPickMembers;
    if (_pickAvatarMembers.length < 4) {
      for (int i = 0; i < widget.news.otherPickMembers.length; i++) {
        _pickAvatarMembers.add(widget.news.otherPickMembers[i]);
        if (_pickAvatarMembers.length == 4) {
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification dSNotification) {
        if (_isCollapsed && dSNotification.extent > 0.3) {
          _isCollapsed = false;
        } else if (!_isCollapsed && dSNotification.extent < 0.3) {
          _isCollapsed = true;
        }
        return false;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: DraggableScrollableActuator(
              child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 0.11,
                minChildSize: 0.11,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isCollapsed)
                          GestureDetector(
                            onTap: () {
                              DraggableScrollableActuator.reset(context);
                              _isCollapsed = true;
                            },
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.expand_more_outlined,
                                color: Colors.black38,
                                size: 32,
                              ),
                            ),
                          ),
                        Flexible(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: _isCollapsed
                                ? _collapseWidget(context)
                                : _expandWidget(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          CommentInputBox(
            member: widget.member,
            onPressed: sendComment,
            isSending: _isSending,
            onTextChanged: (text) => widget.onTextChanged(text),
            textController: _textController,
          ),
        ],
      ),
    );
  }

  Widget _collapseWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 4,
          width: 48,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(top: 16),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 1),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.black38,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              if (widget.news.allComments.isNotEmpty) ...[
                AutoSizeText.rich(
                  TextSpan(
                    text: widget.news.allComments.length.toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    children: const [
                      TextSpan(
                        text: ' 則留言',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                Container(
                  width: 2,
                  height: 2,
                  margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                  ),
                ),
              ],
              if (_pickCount != 0)
                AutoSizeText.rich(
                  TextSpan(
                    text: _pickCount.toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    children: const [
                      TextSpan(
                        text: ' 人精選',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              Expanded(
                child: Container(),
              ),
              _pickButton(
                context,
                widget.news,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _titleAndPickBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.news.title,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.news.source != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.news.source!.title,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              ProfilePhotoStack(_pickAvatarMembers, 14),
              const SizedBox(width: 8),
              if (widget.news.pickCount != 0)
                RichText(
                  text: TextSpan(
                    text: widget.news.pickCount.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
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
                  maxLines: 1,
                ),
              Expanded(
                child: Container(),
              ),
              _pickButton(
                context,
                widget.news,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expandWidget(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      primary: true,
      physics: const ClampingScrollPhysics(),
      children: [
        _titleAndPickBar(),
        if (widget.news.popularComments.isNotEmpty)
          ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.news.popularComments.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: const Text(
                    '熱門留言',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return CommentItem(
                comment: widget.news.popularComments[index],
                member: widget.member,
                isLiked: _allComments[index].isLiked,
                isFollowingComment: widget.member.following?.any((element) =>
                        element.memberId ==
                        _allComments[index].member.memberId) ??
                    false,
                isMyComment: _allComments[index].member.memberId ==
                    widget.member.memberId,
                isSending: (_isSending && index == 0),
                isMyNewComment: _hasMyNewComment && index == 0,
              );
            },
          ),
        if (widget.news.allComments.isNotEmpty)
          ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: widget.news.allComments.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    '所有留言 (${widget.news.allComments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return CommentItem(
                comment: _allComments[index - 1],
                member: widget.member,
                isLiked: _allComments[index - 1].isLiked,
                isFollowingComment: widget.member.following?.any((element) =>
                        element.memberId ==
                        _allComments[index - 1].member.memberId) ??
                    false,
                isMyComment: _allComments[index - 1].member.memberId ==
                    widget.member.memberId,
                isSending: (_isSending && index == 1),
                isMyNewComment: _hasMyNewComment && index == 1,
              );
            },
          ),
      ],
    );
  }

  void sendComment(String text) async {
    if (!_isSending) {
      _myNewComment = Comment(
        id: 'sending',
        member: widget.member,
        content: text,
        state: "public",
        publishDate: DateTime.now(),
      );
      _allComments.insert(0, _myNewComment);
    }
    setState(() {
      _isSending = true;
    });
    List<Comment>? newAllComments = await _commentService.createComment(
      memberId: widget.member.memberId,
      storyId: widget.news.id,
      content: text,
      state: CommentTransparency.public,
    );
    setState(() {
      _isSending = false;
    });
    if (newAllComments != null) {
      _allComments = newAllComments;
      // find new comment position
      int index = _allComments.indexWhere((element) {
        if (element.content == _myNewComment.content &&
            element.member.memberId == _myNewComment.member.memberId) {
          return true;
        }
        return false;
      });
      // if it's not the first, move to first
      if (index != 0 && index != -1) {
        _myNewComment = _allComments.elementAt(index);
        _allComments.removeAt(index);
        _allComments.insert(0, _myNewComment);
      }

      _textController.clear();
      setState(() {
        _hasMyNewComment = true;
      });
      Timer(const Duration(seconds: 5, milliseconds: 5),
          () => _hasMyNewComment = false);
    } else {
      Fluttertoast.showToast(
        msg: "留言失敗，請稍後再試一次",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Widget _pickButton(BuildContext context, NewsStoryItem news) {
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
                      widget.isPickedButton(_isPicked);
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
                      widget.isPickedButton(_isPicked);
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
                      news.pickCount++;
                    } else {
                      // recovery UI when is failed
                      news.myPickId = null;
                      setState(() {
                        _pickCount--;
                        _isPicked = !_isPicked;
                        widget.isPickedButton(_isPicked);
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
                    news.pickCount--;
                    _pickCount--;
                    _isPicked = !_isPicked;
                    widget.isPickedButton(_isPicked);
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
                      widget.isPickedButton(_isPicked);
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
