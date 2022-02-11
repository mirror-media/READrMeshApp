part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class InitialHomeScreen extends HomeEvent {
  final Member currentMember;
  const InitialHomeScreen(this.currentMember);
  @override
  String toString() => 'InitialHomeScreen';
}

class ReloadHomeScreen extends HomeEvent {
  @override
  String toString() => 'ReloadHomeScreen';
}

class RefreshHomeScreen extends HomeEvent {
  @override
  String toString() => 'RefreshHomeScreen';
}

class UpdateFollowingMember extends HomeEvent {
  final Member targetMember;
  final Member currentMember;
  final bool isFollowed;
  const UpdateFollowingMember(
      this.targetMember, this.currentMember, this.isFollowed);
  @override
  String toString() => 'UpdateFollowingMember';
}

class LoadMoreFollowingPicked extends HomeEvent {
  final Member currentMember;
  final DateTime lastPickTime;
  final List<String> alreadyFetchIds;

  const LoadMoreFollowingPicked(
      this.currentMember, this.lastPickTime, this.alreadyFetchIds);

  @override
  String toString() => 'LoadMoreFollowingPicked';
}

class LoadMoreLatestNews extends HomeEvent {
  final Member currentMember;
  final DateTime lastPublishTime;

  const LoadMoreLatestNews(this.currentMember, this.lastPublishTime);

  @override
  String toString() => 'LoadMoreLatestNews';
}
