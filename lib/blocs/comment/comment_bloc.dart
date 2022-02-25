import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/commentService.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentService _commentService = CommentService();

  CommentBloc() : super(CommentInitial()) {
    on<CommentEvent>((event, emit) async {
      print(event.toString());
      try {
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
          emit(CommentAdding());
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
}
