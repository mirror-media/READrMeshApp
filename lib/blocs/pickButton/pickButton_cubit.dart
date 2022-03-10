import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';

part 'pickButton_state.dart';

class PickButtonCubit extends Cubit<PickButtonState> {
  PickButtonCubit() : super(PickButtonInitial());

  updateButton(BuildContext context, PickableItem item, String? comment) async {
    bool originIsPicked = item.pickId != null;
    Comment? pickComment;
    if (comment != null) {
      pickComment = Comment(
        id: 'sendingPickComment',
        member: UserHelper.instance.currentUser,
        content: comment,
        state: "public",
        publishDate: DateTime.now(),
      );
    }
    emit(PickButtonUpdating(
      type: item.type,
      targetId: item.targetId,
      isPicked: !originIsPicked,
      pickComment: pickComment,
      pickCount: originIsPicked ? item.pickCount - 1 : item.pickCount + 1,
    ));

    try {
      if (originIsPicked) {
        bool isSuccess = await item.deletePick();
        PickToast.showPickToast(context, isSuccess, false);
        if (isSuccess) {
          emit(PickButtonUpdateSuccess(
            type: item.type,
            targetId: item.targetId,
            pickId: null,
            pickCount: item.pickCount,
          ));
        } else {
          emit(PickButtonUpdateFailed(
            type: item.type,
            targetId: item.targetId,
            pickId: item.pickId,
            commentId: item.pickCommentId,
            originIsPicked: originIsPicked,
            pickCount: item.pickCount,
          ));
        }
      } else if (comment != null) {
        var result = await item.createPickAndComment(comment);
        PickToast.showPickToast(context, result != null, true);
        if (result != null) {
          emit(PickButtonUpdateSuccess(
            type: item.type,
            targetId: item.targetId,
            pickId: result['pickId'],
            commentId: result['pickComment'].id,
            pickCount: item.pickCount,
          ));
        } else {
          emit(PickButtonUpdateFailed(
            type: item.type,
            targetId: item.targetId,
            pickId: null,
            originIsPicked: originIsPicked,
            pickCount: item.pickCount,
          ));
        }
      } else {
        String? pickId = await item.createPick();
        PickToast.showPickToast(context, pickId != null, true);
        if (pickId != null) {
          emit(PickButtonUpdateSuccess(
            type: item.type,
            targetId: item.targetId,
            pickId: pickId,
            pickCount: item.pickCount,
          ));
        } else {
          emit(PickButtonUpdateFailed(
            type: item.type,
            targetId: item.targetId,
            pickId: null,
            originIsPicked: originIsPicked,
            pickCount: item.pickCount,
          ));
        }
      }
    } catch (e) {
      emit(PickButtonUpdateFailed(
        type: item.type,
        targetId: item.targetId,
        pickId: item.pickId,
        error: e,
        originIsPicked: originIsPicked,
        commentId: item.pickCommentId,
        pickCount: item.pickCount,
      ));
    }
  }
}
