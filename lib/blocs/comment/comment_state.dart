part of 'comment_bloc.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentAdding extends CommentState {
  final Comment myNewComment;
  const CommentAdding(this.myNewComment);
}

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

class AddingPickComment extends CommentState {
  final Comment myNewComment;
  const AddingPickComment(this.myNewComment);
}

class RemovingPickComment extends CommentState {
  final String pickCommentId;
  final PickableItem item;
  const RemovingPickComment(this.pickCommentId, this.item);
}

class PickCommentAdded extends CommentState {
  final Comment comment;
  final PickableItem item;
  const PickCommentAdded(this.comment, this.item);
}

class PickCommentAddFailed extends CommentState {
  final PickableItem item;
  const PickCommentAddFailed(this.item);
}

class PickCommentRemoveFailed extends CommentState {
  final PickableItem item;
  const PickCommentRemoveFailed(this.item);
}

class CommentError extends CommentState {
  final dynamic error;
  const CommentError(this.error);
}

class DeletingComment extends CommentState {
  final String commentId;
  const DeletingComment(this.commentId);
}

class DeleteCommentSuccess extends CommentState {}

class DeleteCommentFailure extends CommentState {}

class UpdatingComment extends CommentState {
  final Comment newComment;
  const UpdatingComment(this.newComment);
}

class UpdateCommentSuccess extends CommentState {}

class UpdateCommentFailure extends CommentState {
  final Comment oldComment;
  const UpdateCommentFailure(this.oldComment);
}
