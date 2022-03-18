import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/commentCountHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/pickableItem.dart';

part 'commentCount_state.dart';

class CommentCountCubit extends Cubit<CommentCountState> {
  final PickButtonCubit pickButtonCubit;
  late final StreamSubscription pickButtonCubitSubscription;
  CommentCountCubit(this.pickButtonCubit) : super(CommentCountInitial()) {
    pickButtonCubitSubscription = pickButtonCubit.stream.listen((state) {
      if (state is PickButtonUpdateSuccess && state.comment != null) {
        if (state.item.objective == PickObjective.story) {
          int newCount = CommentCountHelper.instance
                  .getStoryCommentCount(state.item.targetId) +
              1;
          updateCommentCount(state.item, newCount);
        }
      }

      if (state is RemovePickAndComment) {
        if (state.item.objective == PickObjective.story) {
          int newCount = CommentCountHelper.instance
                  .getStoryCommentCount(state.item.targetId) -
              1;
          updateCommentCount(state.item, newCount);
        }
      }

      if (state is AddPickCommentFailed) {
        if (state.item.objective == PickObjective.story) {
          int newCount = CommentCountHelper.instance
                  .getStoryCommentCount(state.item.targetId) -
              1;
          updateCommentCount(state.item, newCount);
        }
      }

      if (state is RemovePickAndCommentFailed) {
        if (state.item.objective == PickObjective.story) {
          int newCount = CommentCountHelper.instance
                  .getStoryCommentCount(state.item.targetId) +
              1;
          updateCommentCount(state.item, newCount);
        }
      }
    });
  }

  updateCommentCount(PickableItem item, int newCommentCount) {
    emit(CommentCountUpdating());
    if (item.objective == PickObjective.story) {
      CommentCountHelper.instance
          .updateStoryMap(item.targetId, newCommentCount);
    }
    emit(CommentCountUpdated());
  }

  deleteComment(PickableItem item) {
    if (item.objective == PickObjective.story) {
      int newCount =
          CommentCountHelper.instance.getStoryCommentCount(item.targetId) - 1;
      updateCommentCount(item, newCount);
    }
  }

  addComment(PickableItem item) {
    if (item.objective == PickObjective.story) {
      int newCount =
          CommentCountHelper.instance.getStoryCommentCount(item.targetId) + 1;
      updateCommentCount(item, newCount);
    }
  }
}
