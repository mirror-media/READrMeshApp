import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/services/commentService.dart';

class BottomCardWidget extends StatefulWidget {
  final NewsStoryItem news;
  final ValueChanged<String> onTextChanged;
  final bool isPicked;

  const BottomCardWidget({
    required this.news,
    required this.onTextChanged,
    this.isPicked = false,
  });

  @override
  _BottomCardWidgetState createState() => _BottomCardWidgetState();
}

class _BottomCardWidgetState extends State<BottomCardWidget> {
  bool _isPicked = false;
  int _pickCount = 0;
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
    _pickAvatarMembers.addAll(widget.news.otherPickMembers);
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
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          snap: true,
          initialChildSize: 0.22,
          minChildSize: 0.22,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -8),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      slivers: [
                        if (_isCollapsed)
                          SliverToBoxAdapter(
                            child: _collapseWidget(context),
                          ),
                        if (!_isCollapsed) ...[
                          SliverAppBar(
                            centerTitle: true,
                            automaticallyImplyLeading: false,
                            pinned: true,
                            elevation: 0,
                            titleSpacing: 0,
                            backgroundColor: Colors.transparent,
                            title: Container(
                              height: kToolbarHeight,
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
                          SliverToBoxAdapter(
                            child: _titleAndPickBar(),
                          ),
                          if (widget.news.popularComments.isNotEmpty)
                            _popularCommentList(context),
                          SliverAppBar(
                            backgroundColor: Colors.white,
                            title: Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 12),
                              child: Text(
                                '所有留言 (${_allComments.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            centerTitle: false,
                            pinned: true,
                            automaticallyImplyLeading: false,
                            titleSpacing: 0,
                          ),
                          _allCommentList(context),
                        ]
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Divider(
                    color: Colors.black12,
                    thickness: 0.5,
                    height: 0.5,
                  ),
                ),
                CommentInputBox(
                  onPressed: _sendComment,
                  isSending: _isSending,
                  onTextChanged: (text) => widget.onTextChanged(text),
                  textController: _textController,
                  isCollapsed: _isCollapsed,
                ),
              ],
            );
          },
        ),
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
              color: Colors.black26,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
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
              _pickButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _titleAndPickBar() {
    List<Member> memberList = [];
    if (_pickAvatarMembers.length < 4 && _isPicked) {
      memberList.add(UserHelper.instance.currentUser);
    }
    for (int i = 0; i < _pickAvatarMembers.length; i++) {
      memberList.add(_pickAvatarMembers[i]);
      if (memberList.length == 4) {
        break;
      }
    }

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
              if (widget.news.pickCount != 0) ...[
                ProfilePhotoStack(memberList, 14),
                const SizedBox(width: 8),
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
              ],
              if (widget.news.pickCount == 0)
                const Text(
                  '尚無人精選',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              Expanded(
                child: Container(),
              ),
              _pickButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _popularCommentList(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
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
            comment: widget.news.popularComments[index - 1],
            isSending: false,
            isMyNewComment: false,
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0) return Container();
          return const Divider(
            color: Colors.black12,
            thickness: 0.5,
            height: 0.5,
            indent: 20,
            endIndent: 20,
          );
        },
        itemCount: widget.news.popularComments.length + 1,
      ),
    );
  }

  Widget _allCommentList(BuildContext context) {
    return SliverToBoxAdapter(
      key: UniqueKey(),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) => CommentItem(
          comment: _allComments[index],
          isSending: (_isSending && index == 0),
          isMyNewComment: _hasMyNewComment && index == 0,
        ),
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black12,
          thickness: 0.5,
          height: 0.5,
          indent: 20,
          endIndent: 20,
        ),
        itemCount: _allComments.length,
      ),
    );
  }

  void _sendComment(String text) async {
    _myNewComment = Comment(
      id: 'sending',
      member: UserHelper.instance.currentUser,
      content: text,
      state: "public",
      publishDate: DateTime.now(),
    );
    _allComments.insert(0, _myNewComment);
    setState(() {
      _isSending = true;
    });
    List<Comment>? newAllComments = await _commentService.createComment(
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

  Widget _pickButton() {
    return PickButton(
      StoryPick(widget.news.id, widget.news.myPickId),
      afterPicked: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
        });
      },
      afterRemovePick: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
        });
      },
      whenPickFailed: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
        });
      },
      whenRemoveFailed: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
        });
      },
    );
  }
}
