part of 'comment_bloc.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentAdding extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  const CommentLoaded(this.comments);
}

class AddCommentSuccess extends CommentState {
  final List<Comment> comments;
  const AddCommentSuccess(this.comments);
}

class AddCommentFailed extends CommentState {
  final dynamic error;
  const AddCommentFailed(this.error);
}

class CommentError extends CommentState {
  final dynamic error;
  const CommentError(this.error);
}
