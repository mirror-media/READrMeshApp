import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/services/pickService.dart';

part 'pickButton_state.dart';

class PickButtonCubit extends Cubit<PickButtonState> {
  PickButtonCubit() : super(PickButtonInitial());
  final PickService _pickService = PickService();

  updateButton(BuildContext context, PickableItem item, String? comment) async {
    bool originIsPicked = item.isPicked;
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

    PickedItem tempData;
    if (originIsPicked) {
      tempData = UserHelper.instance.getNewsPickedItem(item.targetId)!;
      UserHelper.instance.updateNewsPickedMap(item.targetId, null);
    } else {
      tempData = PickedItem(
        pickId: 'temp',
        pickCount: item.pickCount + 1,
        commentCount:
            comment != null ? item.commentCount + 1 : item.commentCount,
      );
      UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
    }
    emit(PickButtonUpdating(comment: pickComment));

    try {
      if (originIsPicked) {
        bool isSuccess = await _pickService.deletePick(tempData.pickId);
        PickToast.showPickToast(context, isSuccess, false);
        if (!isSuccess) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateFailed());
        } else {
          emit(const PickButtonUpdateSuccess());
        }
      } else if (comment != null) {
        var result = await _pickService.createPickAndComment(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
          commentContent: comment,
        );
        PickToast.showPickToast(context, result != null, true);
        if (result == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed());
        } else {
          tempData.pickId = result['pickId'];
          tempData.pickCommentId = result['pickComment'].id;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateSuccess(comment: result['pickComment']));
        }
      } else {
        String? pickId = await _pickService.createPick(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
        );
        PickToast.showPickToast(context, pickId != null, true);
        if (pickId == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed());
        } else {
          tempData.pickId = pickId;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(const PickButtonUpdateSuccess());
        }
      }
    } catch (e) {
      print("Pick Error: " + e.toString());
      if (originIsPicked) {
        UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
      } else {
        UserHelper.instance.updateNewsPickedMap(item.targetId, null);
      }
      emit(PickButtonUpdateFailed());
    }
  }
}
