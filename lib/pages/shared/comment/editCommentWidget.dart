import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class EditCommentWidget extends StatefulWidget {
  final Comment comment;
  final CommentBloc commentBloc;
  const EditCommentWidget(this.comment, this.commentBloc, {Key? key})
      : super(key: key);

  @override
  State<EditCommentWidget> createState() => _EditCommentWidgetState();
}

class _EditCommentWidgetState extends State<EditCommentWidget> {
  late final TextEditingController _controller;
  bool _hasInput = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.content);
    _controller.addListener(() {
      // check value whether is only space
      if (_controller.text.trim().isNotEmpty) {
        setState(() {
          _hasInput = true;
        });
      } else {
        setState(() {
          _hasInput = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Row(
              children: [
                ProfilePhotoWidget(UserHelper.instance.currentUser, 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    UserHelper.instance.currentUser.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: readrBlack87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              minLines: 1,
              maxLines: 6,
              autofocus: true,
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  _hasInput ? '儲存' : '取消編輯',
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  if (_hasInput) {
                    Comment newComment = Comment(
                      id: widget.comment.id,
                      member: widget.comment.member,
                      content: _controller.text,
                      state: widget.comment.state,
                      publishDate: widget.comment.publishDate,
                      isEdited: true,
                    );

                    widget.commentBloc.add(EditComment(
                        oldComment: widget.comment, newComment: newComment));
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
