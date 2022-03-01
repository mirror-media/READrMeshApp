part of 'publisher_cubit.dart';

abstract class PublisherState extends Equatable {
  const PublisherState();

  @override
  List<Object> get props => [];
}

class PublisherInitial extends PublisherState {}

class PublisherLoading extends PublisherState {}

class PublisherLoadingMore extends PublisherState {}

class PublisherLoaded extends PublisherState {
  final List<NewsListItem> publisherNewsList;
  const PublisherLoaded(this.publisherNewsList);
}

class PublisherError extends PublisherState {
  final dynamic error;
  const PublisherError(this.error);
}

class PublisherLoadMoreFailed extends PublisherState {
  final dynamic error;
  const PublisherLoadMoreFailed(this.error);
}
