import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
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
        add(UpdatePickCommentSuccess(state.comment));
      }

      if (state is PickButtonUpdateFailed) {
        add(UpdatePickCommentFailed());
      }

      if (state is PickButtonUpdating) {
        if (state.comment != null) {
          add(AddPickComment(state.comment!));
        }
      }

      if (state is RemovePickAndComment) {
        add(RemovePickComment(state.commentId));
      }
    });
    on<CommentEvent>((event, emit) async {
      try {
        print(event.toString());
        if (event is FetchComments) {
          emit(CommentLoading());
          List<Comment>? allComments =
              await _commentService.fetchCommentsByStoryId(event.storyId);
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
            storyId: event.storyId,
            content: event.content,
            state: event.commentTransparency,
          );
          if (allComments == null) {
            emit(AddCommentFailed(UnknownException('FetchCommentsFailed')));
          } else {
            emit(AddCommentSuccess(allComments));
          }
        } else if (event is AddPickComment) {
          emit(AddingPickComment(event.comment));
        } else if (event is UpdatePickCommentSuccess) {
          emit(PickCommentUpdateSuccess(event.comment));
        } else if (event is RemovePickComment) {
          emit(RemovingPickComment(event.commentId));
        } else if (event is UpdatePickCommentFailed) {
          emit(PickCommentUpdateFailed());
        }
      } catch (e) {
        if (event is AddComment) {
          emit(AddCommentFailed(e));
        } else if (e is SocketException) {
          emit(CommentError(NoInternetException('No Internet')));
        } else if (e is HttpException) {
          emit(CommentError(NoServiceFoundException('No Service Found')));
        } else if (e is FormatException) {
          emit(CommentError(InvalidFormatException('Invalid Response format')));
        } else if (e is FetchDataException) {
          emit(CommentError(NoInternetException('Error During Communication')));
        } else if (e is BadRequestException ||
            e is UnauthorisedException ||
            e is InvalidInputException) {
          emit(CommentError(Error400Exception('Unauthorised')));
        } else if (e is InternalServerErrorException) {
          emit(CommentError(Error500Exception('Internal Server Error')));
        } else {
          emit(CommentError(UnknownException(e.toString())));
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
