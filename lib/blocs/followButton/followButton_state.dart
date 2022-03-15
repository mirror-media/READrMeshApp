part of 'followButton_cubit.dart';

abstract class FollowButtonState extends Equatable {
  const FollowButtonState();

  @override
  List<Object> get props => [];
}

class FollowButtonInitial extends FollowButtonState {}

class FollowButtonTap extends FollowButtonState {}

class FollowButtonUpdating extends FollowButtonState {}

class FollowButtonUpdated extends FollowButtonState {}
