part of 'commentCount_cubit.dart';

abstract class CommentCountState extends Equatable {
  const CommentCountState();

  @override
  List<Object> get props => [];
}

class CommentCountInitial extends CommentCountState {}

class CommentCountUpdating extends CommentCountState {}

class CommentCountUpdated extends CommentCountState {}
