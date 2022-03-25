import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/blocs/commentCount/commentCount_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/bottomCard/collapsePickBar.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';

class BottomCardWidget extends StatefulWidget {
  final PickableItem item;
  final ValueChanged<String> onTextChanged;
  final bool isPicked;

  const BottomCardWidget({
    required this.item,
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
  bool _isSending = false;
  int _removeIndex = -1;
  late Comment _removeComment;
  late int _deleteCommentIndex;
  late Comment _deleteComment;
  final List<Comment> _popularComments = [];
  late int _deletePopularCommentIndex;

  @override
  void initState() {
    super.initState();
    List<Member> _pickedMembers = [];
    _pickedMembers.addAll(widget.item.pickedMemberList);
    _allComments.addAll(widget.item.allComments);
    _popularComments.addAll(widget.item.popularComments);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocBuilder<CommentBloc, CommentState>(
        builder: (context, state) {
          if (state is CommentAdding && !_isSending) {
            _isSending = true;
            _myNewComment = state.myNewComment;
            _allComments.insert(0, _myNewComment);
          }

          if (state is AddCommentSuccess) {
            _isSending = false;
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
            context
                .read<CommentCountCubit>()
                .updateCommentCount(widget.item, _allComments.length);
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
            _isSending = false;
          }

          if (state is AddingPickComment && !_isSending) {
            _myNewComment = state.myNewComment;
            _allComments.insert(0, _myNewComment);
            _isSending = true;
          }

          if (state is RemovingPickComment) {
            _removeIndex = _allComments
                .indexWhere((element) => element.id == state.pickCommentId);
            if (_removeIndex != -1) {
              _removeComment = _allComments[_removeIndex];
              _allComments.removeAt(_removeIndex);
            }
            _deletePopularCommentIndex = _popularComments
                .indexWhere((element) => element.id == state.pickCommentId);
            if (_deletePopularCommentIndex != -1) {
              _popularComments.removeAt(_deletePopularCommentIndex);
            }
          }

          if (state is PickCommentAdded) {
            _isSending = false;
            _allComments[0] = state.comment;
            _hasMyNewComment = true;
            Timer(const Duration(seconds: 5, milliseconds: 5),
                () => _hasMyNewComment = false);
          }

          if (state is PickCommentAddFailed) {
            _isSending = false;
            _allComments.removeAt(0);
          }

          if (state is PickCommentRemoveFailed) {
            _allComments.insert(_removeIndex, _removeComment);
            if (_deletePopularCommentIndex != -1) {
              _popularComments.insert(
                  _deletePopularCommentIndex, _removeComment);
            }
          }

          if (state is DeletingComment) {
            _deleteCommentIndex = _allComments
                .indexWhere((element) => element.id == state.commentId);
            if (_deleteCommentIndex != -1) {
              _deleteComment = _allComments[_deleteCommentIndex];
              _allComments.removeAt(_deleteCommentIndex);
              context
                  .read<CommentCountCubit>()
                  .updateCommentCount(widget.item, _allComments.length);
            }
            _deletePopularCommentIndex = _popularComments
                .indexWhere((element) => element.id == state.commentId);
            if (_deletePopularCommentIndex != -1) {
              _popularComments.removeAt(_deletePopularCommentIndex);
            }
          }

          if (state is DeleteCommentFailure) {
            _allComments.insert(_deleteCommentIndex, _deleteComment);
            if (_deletePopularCommentIndex != -1) {
              _popularComments.insert(
                  _deletePopularCommentIndex, _deleteComment);
            }
            context
                .read<CommentCountCubit>()
                .updateCommentCount(widget.item, _allComments.length);
          }

          if (state is UpdatingComment) {
            int index = _allComments
                .indexWhere((element) => element.id == state.newComment.id);
            if (index != -1) {
              _allComments[index] = state.newComment;
            }
            int popularIndex = _popularComments
                .indexWhere((element) => element.id == state.newComment.id);
            if (popularIndex != -1) {
              _popularComments[popularIndex] = state.newComment;
            }
          }

          if (state is UpdateCommentFailure) {
            int index = _allComments
                .indexWhere((element) => element.id == state.oldComment.id);
            if (index != -1) {
              _allComments[index] = state.oldComment;
            }
            int popularIndex = _popularComments
                .indexWhere((element) => element.id == state.oldComment.id);
            if (popularIndex != -1) {
              _popularComments[popularIndex] = state.oldComment;
            }
          }

          if (state is UpdateCommentLike) {
            int allCommentsIndex = _allComments
                .indexWhere((element) => element == state.newComment);
            if (allCommentsIndex != -1) {
              _allComments[allCommentsIndex] = state.newComment;
            }

            int popularCommentsIndex = _popularComments
                .indexWhere((element) => element == state.newComment);
            if (popularCommentsIndex != -1) {
              _popularComments[popularCommentsIndex] = state.newComment;
            }
          }

          double height = MediaQuery.of(context).size.height;
          double size = (-0.0002 * height) + 0.3914;

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
                initialChildSize: size,
                minChildSize: size,
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
                                color: readrBlack10,
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
                                      color: readrBlack30,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: _titleAndPickBar(),
                                ),
                                if (_popularComments.isNotEmpty)
                                  _popularCommentList(context),
                                SliverAppBar(
                                  backgroundColor: Colors.white,
                                  title: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 16, 20, 12),
                                    child: Text(
                                      '所有留言 (${_allComments.length})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: readrBlack87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  centerTitle: false,
                                  pinned: true,
                                  automaticallyImplyLeading: false,
                                  titleSpacing: 0,
                                  elevation: 0.5,
                                ),
                                _allCommentList(context),
                              ]
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 16),
                        child: const Divider(
                          color: readrBlack10,
                          thickness: 0.5,
                          height: 1,
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
              color: readrBlack20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: CollapsePickBar(widget.item, _allComments.length),
        ),
      ],
    );
  }

  Widget _titleAndPickBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: readrBlack10, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.title,
            maxLines: 2,
            style: const TextStyle(
              color: readrBlack87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.item.author,
            maxLines: 1,
            style: const TextStyle(
              color: readrBlack50,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          PickBar(widget.item),
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
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return CommentItem(
            comment: _popularComments[index - 1],
            isSending: false,
            isMyNewComment: false,
            key: ValueKey(_popularComments[index - 1].id +
                _popularComments[index - 1].likedCount.toString()),
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0) return Container();
          return const Divider(
            color: readrBlack10,
            thickness: 0.5,
            height: 0.5,
            indent: 20,
            endIndent: 20,
          );
        },
        itemCount: _popularComments.length + 1,
      ),
    );
  }

  Widget _allCommentList(BuildContext context) {
    if (_allComments.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '還沒有人留言，快來搶頭香！',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) => CommentItem(
          comment: _allComments[index],
          isSending: (_isSending && index == 0),
          isMyNewComment: _hasMyNewComment && index == 0,
          key: ValueKey(_allComments[index].id +
              _allComments[index].likedCount.toString()),
        ),
        separatorBuilder: (context, index) => const Divider(
          color: readrBlack10,
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
    context.read<CommentBloc>().add(AddComment(
          targetId: widget.item.targetId,
          content: text,
          objective: widget.item.objective,
        ));
    _hasMyNewComment = true;
  }
}
