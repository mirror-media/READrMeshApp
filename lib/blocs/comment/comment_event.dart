part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class FetchComments extends CommentEvent {
  final String storyId;
  final String memberId;

  const FetchComments(this.storyId, this.memberId);

  @override
  String toString() => "Fetch comments";
}

class AddComment extends CommentEvent {
  final String storyId;
  final String memberId;
  final String content;
  final CommentTransparency commentTransparency;

  const AddComment({
    required this.storyId,
    required this.memberId,
    required this.content,
    required this.commentTransparency,
  });

  @override
  String toString() => "Add comment";
}