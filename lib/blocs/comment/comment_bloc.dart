import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/services/commentService.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentService _commentService = CommentService();
  final PickButtonCubit pickButtonCubit;
  late final StreamSubscription pickButtonCubitSubscription;

  CommentBloc(this.pickButtonCubit) : super(CommentInitial()) {
    pickButtonCubitSubscription = pickButtonCubit.stream.listen((state) {
      if (state is PickButtonUpdateSuccess && state.comment != null) {
        add(AddPickCommentSuccess(state.comment!, state.item));
      }

      if (state is AddPickCommentFailed) {
        add(UpdatePickCommentFailed(state.item, true));
      }

      if (state is RemovePickAndCommentFailed) {
        add(UpdatePickCommentFailed(state.item, false));
      }

      if (state is PickButtonUpdating) {
        if (state.comment != null) {
          add(AddPickComment(state.comment!, state.item));
        }
      }

      if (state is RemovePickAndComment) {
        add(RemovePickComment(state.commentId, state.item));
      }
    });
    on<CommentEvent>((event, emit) async {
      try {
        print(event.toString());
        if (event is FetchComments) {
          emit(CommentLoading());
          List<Comment>? allComments =
              await _commentService.fetchCommentsByStoryId(event.targetId);
          if (allComments == null) {
            emit(CommentError(UnknownException('FetchCommentsFailed')));
          } else {
            emit(CommentLoaded(allComments));
          }
        } else if (event is AddComment) {
          Comment myNewComment = Comment(
            id: 'sending',
            member: UserHelper.instance.currentUser,
            content: event.content,
            state: "public",
            publishDate: DateTime.now(),
          );
          emit(CommentAdding(myNewComment));
          List<Comment>? allComments = await _commentService.createComment(
            storyId: event.targetId,
            content: event.content,
            state: CommentTransparency.public,
          );
          if (allComments == null) {
            emit(AddCommentFailed(UnknownException('FetchCommentsFailed')));
          } else {
            emit(AddCommentSuccess(allComments));
          }
        } else if (event is AddPickComment) {
          emit(AddingPickComment(event.comment));
        } else if (event is AddPickCommentSuccess) {
          emit(PickCommentAdded(event.comment, event.item));
        } else if (event is RemovePickComment) {
          emit(RemovingPickComment(event.commentId, event.item));
        } else if (event is UpdatePickCommentFailed) {
          if (event.isAdd) {
            emit(PickCommentAddFailed(event.item));
          } else {
            emit(PickCommentRemoveFailed(event.item));
          }
        } else if (event is DeleteComment) {
          emit(DeletingComment(event.comment.id));
          var result = await _commentService.deleteComment(event.comment.id);
          if (result) {
            if (event.comment.story != null) {
              UserHelper.instance
                  .removeNewsPickCommentId(event.comment.story!.id);
            }
            emit(DeleteCommentSuccess());
          } else {
            emit(DeleteCommentFailure());
          }
        } else if (event is EditComment) {
          emit(UpdatingComment(event.newComment));
          var result = await _commentService.editComment(event.newComment);
          if (result) {
            emit(UpdateCommentSuccess());
          } else {
            emit(UpdateCommentFailure(event.oldComment));
          }
        }
      } catch (e) {
        if (event is AddComment) {
          emit(AddCommentFailed(e));
        } else if (event is DeleteComment) {
          emit(DeleteCommentFailure());
        } else if (event is EditComment) {
          emit(UpdateCommentFailure(event.oldComment));
        } else {
          emit(CommentError(determineException(e)));
        }
      }
    });
  }

  @override
  Future<void> close() {
    pickButtonCubitSubscription.cancel();
    return super.close();
  }
}
