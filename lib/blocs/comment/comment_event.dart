part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class FetchComments extends CommentEvent {
  final String storyId;

  const FetchComments(this.storyId);

  @override
  String toString() => "Fetch comments";
}

class AddComment extends CommentEvent {
  final String storyId;
  final String content;
  final CommentTransparency commentTransparency;

  const AddComment({
    required this.storyId,
    required this.content,
    required this.commentTransparency,
  });

  @override
  String toString() => "Add comment";
}

class AddPickComment extends CommentEvent {
  final Comment comment;

  const AddPickComment(this.comment);

  @override
  String toString() => "Add pick_comment";
}

class AddPickCommentSuccess extends CommentEvent {
  final Comment comment;
  const AddPickCommentSuccess(this.comment);
  @override
  String toString() => "Add pick_comment success";
}

class UpdatePickCommentFailed extends CommentEvent {
  @override
  String toString() => "Update pick_comment failed";
}

class RemovePickComment extends CommentEvent {
  final String commentId;
  final String targetId;
  final PickObjective objective;
  const RemovePickComment(this.commentId, this.targetId, this.objective);

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
