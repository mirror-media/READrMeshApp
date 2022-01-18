part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class InitialHomeScreen extends HomeEvent {
  @override
  String toString() => 'InitialHomeScreen';
}

class ReloadHomeScreen extends HomeEvent {
  @override
  String toString() => 'InitialHomeScreen';
}

class UpdateFollowingMember extends HomeEvent {
  final String targetId;
  final String userId;
  final bool isFollowed;
  const UpdateFollowingMember(this.targetId, this.userId, this.isFollowed);
  @override
  String toString() => 'UpdateFollowingMember';
}
