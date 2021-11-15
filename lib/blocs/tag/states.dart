part of 'bloc.dart';

enum TagStoryListStatus {
  initial,
  loading,
  loadingMore,
  loadingMoreFail,
  loaded,
  error,
}

class TagStoryListState extends Equatable {
  final TagStoryListStatus status;
  final StoryListItemList? tagStoryList;
  final dynamic error;
  const TagStoryListState._({
    required this.status,
    this.tagStoryList,
    this.error,
  });

  const TagStoryListState.initial()
      : this._(status: TagStoryListStatus.initial);

  const TagStoryListState.loading()
      : this._(status: TagStoryListStatus.loading);

  const TagStoryListState.loaded({
    required StoryListItemList tagStoryList,
  }) : this._(
          status: TagStoryListStatus.loaded,
          tagStoryList: tagStoryList,
        );

  const TagStoryListState.loadingMore({
    required StoryListItemList tagStoryList,
  }) : this._(
          status: TagStoryListStatus.loadingMore,
          tagStoryList: tagStoryList,
        );

  const TagStoryListState.loadingMoreFail({
    required StoryListItemList tagStoryList,
  }) : this._(
          status: TagStoryListStatus.loadingMoreFail,
          tagStoryList: tagStoryList,
        );

  const TagStoryListState.error({required dynamic error})
      : this._(status: TagStoryListStatus.error, error: error);

  @override
  List<Object> get props => [status];
}
