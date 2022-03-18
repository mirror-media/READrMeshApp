part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class FetchComments extends CommentEvent {
  final String targetId;
  final PickObjective objective;

  const FetchComments(this.targetId, this.objective);

  @override
  String toString() => "Fetch comments";
}

class AddComment extends CommentEvent {
  final PickObjective objective;
  final String targetId;
  final String content;

  const AddComment({
    required this.targetId,
    required this.content,
    required this.objective,
  });

  @override
  String toString() => "Add comment";
}

class AddPickComment extends CommentEvent {
  final Comment comment;
  final PickableItem item;

  const AddPickComment(this.comment, this.item);

  @override
  String toString() => "Add pick_comment";
}

class AddPickCommentSuccess extends CommentEvent {
  final Comment comment;
  final PickableItem item;
  const AddPickCommentSuccess(this.comment, this.item);
  @override
  String toString() => "Add pick_comment success";
}

class UpdatePickCommentFailed extends CommentEvent {
  final PickableItem item;
  final bool isAdd;
  const UpdatePickCommentFailed(this.item, this.isAdd);

  @override
  String toString() => "Update pick_comment failed";
}

class RemovePickComment extends CommentEvent {
  final String commentId;
  final PickableItem item;
  const RemovePickComment(this.commentId, this.item);

  @override
  String toString() => "Remove pick_comment commentId = $commentId";
}

class DeleteComment extends CommentEvent {
  final Comment comment;
  const DeleteComment(this.comment);

  @override
  String toString() => "Delete comment commentId = ${comment.id}";
}

class EditComment extends CommentEvent {
  final Comment oldComment;
  final Comment newComment;
  const EditComment({required this.oldComment, required this.newComment});

  @override
  String toString() => "Edit comment commentId = ${oldComment.id}";
}
