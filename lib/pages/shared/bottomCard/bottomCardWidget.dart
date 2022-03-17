import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/bottomCard/collapsePickBar.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';

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
  final TextEditingController _textController = TextEditingController();
  List<Comment> _allComments = [];
  bool _hasMyNewComment = false;
  late Comment _myNewComment;
  bool _isCollapsed = true;
  late final NewsStoryItemPick _pick;
  bool _isSending = false;
  // true mean add, false mean remove
  bool _isAddOrRemove = false;
  int _removeIndex = -1;
  late Comment _removeComment;

  @override
  void initState() {
    super.initState();
    List<Member> _pickedMembers = [];
    _pickedMembers.addAll(widget.news.followingPickMembers);
    _pickedMembers.addAll(widget.news.otherPickMembers);
    _pick = NewsStoryItemPick(widget.news);
    _allComments.addAll(widget.news.allComments);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        _isSending = false;

        if (state is CommentAdding) {
          _isSending = true;
          _myNewComment = state.myNewComment;
          _allComments.insert(0, _myNewComment);
        }

        if (state is AddCommentSuccess) {
          _allComments = state.comments;

          int index = _allComments.indexWhere((element) {
            if (element.content == _myNewComment.content &&
                element.member.memberId == _myNewComment.member.memberId) {
              return true;
            }
            return false;
          });
          if (index != 0 && index != -1) {
            _myNewComment = _allComments.elementAt(index);
            _allComments.removeAt(index);
            _allComments.insert(0, _myNewComment);
          }

          Timer(const Duration(seconds: 5, milliseconds: 5),
              () => _hasMyNewComment = false);
          _textController.clear();
        }

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
          _hasMyNewComment = false;
        }

        if (state is AddingPickComment) {
          _myNewComment = state.myNewComment;
          _allComments.insert(0, _myNewComment);
          _isAddOrRemove = true;
          _isSending = true;
        }

        if (state is RemovingPickComment) {
          _removeIndex = _allComments
              .indexWhere((element) => element.id == state.pickCommentId);
          if (_removeIndex != -1) {
            _removeComment = _allComments[_removeIndex];
            _allComments.removeAt(_removeIndex);
          }

          _isAddOrRemove = false;
        }

        if (state is PickCommentUpdateSuccess && _isAddOrRemove) {
          if (state.comment != null) {
            _allComments[0] = state.comment!;
          }
          _hasMyNewComment = true;
          Timer(const Duration(seconds: 5, milliseconds: 5),
              () => _hasMyNewComment = false);
        }

        if (state is PickCommentUpdateFailed) {
          if (_isAddOrRemove) {
            _allComments.removeAt(0);
          } else {
            _allComments.insert(_removeIndex, _removeComment);
          }
        }

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
              initialChildSize: 0.2,
              minChildSize: 0.2,
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
      },
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
          child: CollapsePickBar(_pick),
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
          PickBar(_pick),
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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) => CommentItem(
          comment: _allComments[index],
          isSending: (_isSending && index == 0),
          isMyNewComment: _hasMyNewComment && index == 0,
          key: ValueKey(_allComments[index].id),
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
    ;
  }

  void _sendComment(String text) async {
    context.read<CommentBloc>().add(AddComment(
          storyId: widget.news.id,
          content: text,
          commentTransparency: CommentTransparency.public,
        ));
    _hasMyNewComment = true;
  }
}
