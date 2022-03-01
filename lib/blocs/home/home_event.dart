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
  String toString() => 'ReloadHomeScreen';
}

class RefreshHomeScreen extends HomeEvent {
  @override
  String toString() => 'RefreshHomeScreen';
}

class UpdateFollowingMember extends HomeEvent {
  final String memberId;
  final bool isFollowing;
  const UpdateFollowingMember(this.memberId, this.isFollowing);
  @override
  String toString() => 'UpdateFollowingMember';
}

class UpdateFollowingPublisher extends HomeEvent {
  final String memberId;
  final bool isFollowing;
  const UpdateFollowingPublisher(this.memberId, this.isFollowing);
  @override
  String toString() => 'UpdateFollowingPublisher';
}

class LoadMoreFollowingPicked extends HomeEvent {
  final DateTime lastPickTime;
  final List<String> alreadyFetchIds;

  const LoadMoreFollowingPicked(this.lastPickTime, this.alreadyFetchIds);

  @override
  String toString() => 'LoadMoreFollowingPicked';
}

class LoadMoreLatestNews extends HomeEvent {
  final DateTime lastPublishTime;

  const LoadMoreLatestNews(this.lastPublishTime);

  @override
  String toString() => 'LoadMoreLatestNews';
}
