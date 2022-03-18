import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/services/pickService.dart';

part 'pickButton_state.dart';

class PickButtonCubit extends Cubit<PickButtonState> {
  PickButtonCubit() : super(PickButtonInitial());
  final PickService _pickService = PickService();

  updateButton(PickableItem item, String? comment) async {
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
        bool isSuccess;
        if (tempData.pickCommentId != null) {
          emit(RemovePickAndComment(
              tempData.pickCommentId!, item.targetId, item.objective));
          isSuccess = await _pickService.deletePickAndComment(
              tempData.pickId, tempData.pickCommentId!);
        } else {
          isSuccess = await _pickService.deletePick(tempData.pickId);
        }

        if (!isSuccess) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateFailed(originIsPicked));
        } else {
          emit(const PickButtonUpdateSuccess(false));
        }
      } else if (comment != null) {
        var result = await _pickService.createPickAndComment(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
          commentContent: comment,
        );

        if (result == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed(originIsPicked));
        } else {
          tempData.pickId = result['pickId'];
          tempData.pickCommentId = result['pickComment'].id;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateSuccess(true, comment: result['pickComment']));
        }
      } else {
        String? pickId = await _pickService.createPick(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
        );

        if (pickId == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed(originIsPicked));
        } else {
          tempData.pickId = pickId;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(const PickButtonUpdateSuccess(true));
        }
      }
    } catch (e) {
      print("Pick Error: " + e.toString());
      if (originIsPicked) {
        UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
      } else {
        UserHelper.instance.updateNewsPickedMap(item.targetId, null);
      }
      emit(PickButtonUpdateFailed(originIsPicked));
    }
  }
}
