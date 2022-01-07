part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadingMore extends HomeState {}

class HomeLoaded extends HomeState {
  final List<NewsListItem> newsList;
  const HomeLoaded(this.newsList);
}

class HomeError extends HomeState {
  final dynamic error;
  const HomeError(this.error);
}

class HomeLoadingMoreFailed extends HomeState {
  final List<NewsListItem> newsList;
  final dynamic error;
  const HomeLoadingMoreFailed(this.newsList, this.error);
}
