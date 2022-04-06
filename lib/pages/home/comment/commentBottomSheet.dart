import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheetWidget.dart';
import 'package:readr/services/commentService.dart';

class CommentBottomSheet {
  static Future<void> showCommentBottomSheet({
    required BuildContext context,
    required Comment clickComment,
    required PickableItem item,
    String? oldContent,
  }) async {
    String? inputContent;
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(24),
      builder: (context) => BlocProvider(
        create: (context) => CommentBloc(
          pickButtonCubit: BlocProvider.of<PickButtonCubit>(context),
          commentRepos: CommentService(),
        ),
        child: SafeArea(
          bottom: false,
          child: Material(
            child: CommentBottomSheetWidget(
              context: context,
              clickComment: clickComment,
              item: item,
              onTextChanged: (text) => inputContent = text,
              oldContent: oldContent,
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      // when there has text, show hint
      if (inputContent != null && inputContent!.trim().isNotEmpty) {
        Widget dialogTitle = const Text(
          '確定要刪除留言？',
          style: TextStyle(
            color: readrBlack,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        );
        Widget dialogContent = const Text(
          '系統將不會儲存您剛剛輸入的內容',
          style: TextStyle(
            color: readrBlack,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        );
        List<Widget> dialogActions = [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () async {
              Navigator.pop(context);
              await showCommentBottomSheet(
                context: context,
                clickComment: clickComment,
                item: item,
                oldContent: inputContent,
              );
            },
            child: const Text(
              '繼續輸入',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ];
        if (!Platform.isIOS) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: dialogTitle,
              content: dialogContent,
              buttonPadding: const EdgeInsets.only(left: 32, right: 8),
              actions: dialogActions,
            ),
          );
        } else {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: dialogTitle,
              content: dialogContent,
              actions: dialogActions,
            ),
          );
        }
      }
    });
  }
}
