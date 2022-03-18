import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/comment/editCommentWidget.dart';

class EditCommentMenu {
  static Future<void> showEditCommentMenu(
    BuildContext context,
    Comment comment,
    CommentBloc commentBloc,
  ) async {
    var result = await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('edit'),
            child: const Text(
              '編輯留言',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: const Text(
              '刪除留言',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Color.fromRGBO(255, 59, 48, 1),
              ),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text(
            '取消',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
    if (result == 'edit') {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: EditCommentWidget(comment, commentBloc),
          );
        },
      );
    } else if (result == 'delete') {
      Widget? dialogContent;
      var item =
          UserHelper.instance.getNewsPickedItemByPickCommentId(comment.id);
      if (item != null) {
        dialogContent = const Text(
          '系統仍會保留您的精選記錄',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        );
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(
            '確定要刪除留言？',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: dialogContent,
          actions: [
            TextButton(
              onPressed: () {
                commentBloc.add(DeleteComment(comment));
                Navigator.pop(context);
              },
              child: const Text(
                '刪除留言',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
