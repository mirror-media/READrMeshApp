import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';

import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class EditCommentWidget extends StatefulWidget {
  final Comment comment;
  const EditCommentWidget(this.comment, {Key? key}) : super(key: key);

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
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Row(
              children: [
                ProfilePhotoWidget(Get.find<UserService>().currentUser, 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Get.find<UserService>().currentUser.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
            TextField(
              minLines: 1,
              maxLines: 6,
              autofocus: true,
              controller: _controller,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'commentTextFieldHint'.tr,
                hintStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 16),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  _hasInput ? 'save'.tr : 'cancelEdit'.tr,
                  style: TextStyle(
                    color: Theme.of(context).extension<CustomColors>()?.blue,
                  ),
                ),
                onPressed: () async {
                  if (_hasInput) {
                    Comment newComment =
                        Comment.editComment(_controller.text, widget.comment);

                    Get.find<CommentItemController>(tag: widget.comment.id)
                        .editComment(newComment);
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
