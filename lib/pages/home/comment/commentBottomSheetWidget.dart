import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBottomSheetWidget extends StatefulWidget {
  final BuildContext context;
  final ScrollController? controller;
  final Member member;
  final Comment clickComment;
  final String storyId;
  final ValueChanged<String> onTextChanged;
  final String? oldContent;

  const CommentBottomSheetWidget({
    required this.context,
    required this.member,
    required this.clickComment,
    required this.storyId,
    this.controller,
    required this.onTextChanged,
    this.oldContent,
  });

  @override
  _CommentBottomSheetWidgetState createState() =>
      _CommentBottomSheetWidgetState();
}

class _CommentBottomSheetWidgetState extends State<CommentBottomSheetWidget> {
  List<Comment> _allComments = [];
  late Comment _myNewComment;
  bool _isSending = false;
  bool _hasMyNewComment = false;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _fetchComment();
    _textController = TextEditingController(text: widget.oldContent);
  }

  _fetchComment() {
    context
        .read<CommentBloc>()
        .add(FetchComments(widget.storyId, widget.member.memberId));
  }

  _createComment(String content) {
    if (!_isSending) {
      context.read<CommentBloc>().add(AddComment(
            storyId: widget.storyId,
            memberId: widget.member.memberId,
            content: content,
            commentTransparency: CommentTransparency.public,
          ));
      _myNewComment = Comment(
        id: 'sending',
        member: widget.member,
        content: content,
        state: "public",
        publishDate: DateTime.now(),
      );
      _isSending = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is AddCommentFailed) {
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
      },
      builder: (context, state) {
        if (state is CommentError) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: Colors.white,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
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
                  SizedBox(
                    height: 500,
                    child: ErrorPage(
                      error: state.error,
                      onPressed: () => _fetchComment(),
                      hideAppbar: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CommentLoaded) {
          _allComments = state.comments;
          return _buildContent();
        }

        if (state is AddCommentFailed) {
          if (_allComments[0].id == 'sending') {
            _allComments.removeAt(0);
          }
          _isSending = false;
          return _buildContent();
        }

        if (state is AddCommentSuccess) {
          _allComments = state.comments;

          // find new comment position
          int index = _allComments.indexWhere((element) {
            if (element.content == _myNewComment.content &&
                element.member.memberId == _myNewComment.member.memberId) {
              return true;
            }
            return false;
          });

          //if not found, just return new comments
          if (index == -1) {
            return _buildContent();
          }

          // if it's not the first, move to first
          if (index != 0) {
            _myNewComment = _allComments.elementAt(index);
            _allComments.removeAt(index);
            _allComments.insert(0, _myNewComment);
          }
          _hasMyNewComment = true;
          if (_isSending) {
            Timer(const Duration(seconds: 5, milliseconds: 5),
                () => _hasMyNewComment = false);
          }

          _isSending = false;
          _textController.clear();

          return _buildContent();
        }

        if (state is CommentAdding) {
          _allComments.insert(0, _myNewComment);
          return _buildContent();
        }

        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Colors.white,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
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
                const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
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
              child: ListView.builder(
                key: UniqueKey(),
                itemCount: _allComments.length,
                controller: widget.controller,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CommentItem(
                    comment: _allComments[index],
                    isLiked: _allComments[index].isLiked,
                    isFollowingComment: widget.member.following?.any(
                            (element) =>
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
            ),
            if (widget.member.memberId != '-1') ...[
              const Divider(
                color: Colors.black12,
                thickness: 0.5,
                height: 0.5,
              ),
              CommentInputBox(
                member: widget.member,
                isSending: _isSending,
                onPressed: (text) {
                  _createComment(text);
                },
                onTextChanged: widget.onTextChanged,
                textController: _textController,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
