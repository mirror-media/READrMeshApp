part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReloading extends HomeState {}

class UpdatingFollowing extends HomeState {}

class UpdateFollowingSuccess extends HomeState {
  final List<Member> newFollowingMembers;
  final bool isFollowed;
  const UpdateFollowingSuccess(this.newFollowingMembers, this.isFollowed);
}

class HomeLoaded extends HomeState {
  final Map<String, dynamic> data;
  const HomeLoaded(this.data);
}

class HomeError extends HomeState {
  final dynamic error;
  const HomeError(this.error);
}

class HomeReloadFailed extends HomeState {
  final dynamic error;
  const HomeReloadFailed(this.error);
}

class UpdateFollowingFailed extends HomeState {
  final dynamic error;
  final bool isFollowed;
  const UpdateFollowingFailed(this.error, this.isFollowed);
}
