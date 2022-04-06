import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/services/pickService.dart';

part 'pickButton_state.dart';

class PickButtonCubit extends Cubit<PickButtonState> {
  final PickRepos pickRepos;
  PickButtonCubit({required this.pickRepos}) : super(PickButtonInitial());

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
      );
      UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
    }
    emit(PickButtonUpdating(item, comment: pickComment));

    try {
      if (originIsPicked) {
        bool isSuccess;
        if (tempData.pickCommentId != null) {
          emit(RemovePickAndComment(tempData.pickCommentId!, item));
          isSuccess = await pickRepos.deletePickAndComment(
              tempData.pickId, tempData.pickCommentId!);
        } else {
          isSuccess = await pickRepos.deletePick(tempData.pickId);
        }

        if (!isSuccess) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          if (tempData.pickCommentId != null) {
            emit(RemovePickAndCommentFailed(item));
          }
          emit(PickButtonUpdateFailed(item, originIsPicked));
        } else {
          emit(PickButtonUpdateSuccess(false, item));
        }
      } else if (comment != null) {
        var result = await pickRepos.createPickAndComment(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
          commentContent: comment,
        );

        if (result == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(AddPickCommentFailed(item));
          emit(PickButtonUpdateFailed(item, originIsPicked));
        } else {
          tempData.pickId = result['pickId'];
          tempData.pickCommentId = result['pickComment'].id;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateSuccess(true, item,
              comment: result['pickComment']));
        }
      } else {
        String? pickId = await pickRepos.createPick(
          targetId: item.targetId,
          objective: item.objective,
          state: PickState.public,
          kind: PickKind.read,
        );

        if (pickId == null) {
          UserHelper.instance.updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed(item, originIsPicked));
        } else {
          tempData.pickId = pickId;
          UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateSuccess(true, item));
        }
      }
    } catch (e) {
      print("Pick Error: " + e.toString());
      if (originIsPicked) {
        UserHelper.instance.updateNewsPickedMap(item.targetId, tempData);
        if (tempData.pickCommentId != null) {
          emit(RemovePickAndCommentFailed(item));
        }
      } else {
        UserHelper.instance.updateNewsPickedMap(item.targetId, null);
        if (comment != null) {
          emit(AddPickCommentFailed(item));
        }
      }
      emit(PickButtonUpdateFailed(item, originIsPicked));
    }
  }
}
