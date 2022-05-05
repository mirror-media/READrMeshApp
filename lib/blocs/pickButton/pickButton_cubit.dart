import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
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
        member: Get.find<UserService>().currentUser,
        content: comment,
        state: "public",
        publishDate: DateTime.now(),
      );
    }

    PickedItem tempData;
    if (originIsPicked) {
      tempData = Get.find<UserService>().getNewsPickedItem(item.targetId)!;
      Get.find<UserService>().updateNewsPickedMap(item.targetId, null);
    } else {
      tempData = PickedItem(
        pickId: 'temp',
        pickCount: item.pickCount + 1,
      );
      Get.find<UserService>().updateNewsPickedMap(item.targetId, tempData);
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
          Get.find<UserService>().updateNewsPickedMap(item.targetId, tempData);
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
          Get.find<UserService>().updateNewsPickedMap(item.targetId, null);
          emit(AddPickCommentFailed(item));
          emit(PickButtonUpdateFailed(item, originIsPicked));
        } else {
          tempData.pickId = result['pickId'];
          tempData.pickCommentId = result['pickComment'].id;
          Get.find<UserService>().updateNewsPickedMap(item.targetId, tempData);
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
          Get.find<UserService>().updateNewsPickedMap(item.targetId, null);
          emit(PickButtonUpdateFailed(item, originIsPicked));
        } else {
          tempData.pickId = pickId;
          Get.find<UserService>().updateNewsPickedMap(item.targetId, tempData);
          emit(PickButtonUpdateSuccess(true, item));
        }
      }
    } catch (e) {
      print("Pick Error: " + e.toString());
      if (originIsPicked) {
        Get.find<UserService>().updateNewsPickedMap(item.targetId, tempData);
        if (tempData.pickCommentId != null) {
          emit(RemovePickAndCommentFailed(item));
        }
      } else {
        Get.find<UserService>().updateNewsPickedMap(item.targetId, null);
        if (comment != null) {
          emit(AddPickCommentFailed(item));
        }
      }
      emit(PickButtonUpdateFailed(item, originIsPicked));
    }
  }
}
