part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReloading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<NewsListItem> allLatestNews;
  final List<NewsListItem> followingStories;
  final List<NewsListItem> latestComments;
  final List<MemberFollowableItem> recommendedMembers;
  final List<PublisherFollowableItem> recommendedPublishers;
  final bool showPaywall;
  final bool showFullScreenAd;
  final bool showSyncToast;
  const HomeLoaded({
    required this.allLatestNews,
    required this.followingStories,
    required this.latestComments,
    required this.recommendedMembers,
    required this.showFullScreenAd,
    required this.showPaywall,
    required this.recommendedPublishers,
    this.showSyncToast = false,
  });
}

class HomeError extends HomeState {
  final dynamic error;
  const HomeError(this.error);
}

class HomeReloadFailed extends HomeState {
  final dynamic error;
  const HomeReloadFailed(this.error);
}

class LoadingMoreFollowingPicked extends HomeState {}

class LoadMoreFollowingPickedSuccess extends HomeState {
  final List<NewsListItem> newFollowingStories;
  const LoadMoreFollowingPickedSuccess(this.newFollowingStories);
}

class LoadMoreFollowingPickedFailed extends HomeState {
  final dynamic error;
  const LoadMoreFollowingPickedFailed(this.error);
}

class LoadingMoreNews extends HomeState {}

class LoadMoreNewsSuccess extends HomeState {
  final List<NewsListItem> newLatestNews;
  const LoadMoreNewsSuccess(this.newLatestNews);
}

class LoadMoreNewsFailed extends HomeState {
  final dynamic error;
  const LoadMoreNewsFailed(this.error);
}
