part of 'bloc.dart';

enum AuthorStoryListStatus {
  initial,
  loading,
  loadingMore,
  loadingMoreFail,
  loaded,
  error,
}

class AuthorStoryListState extends Equatable {
  final AuthorStoryListStatus status;
  final StoryListItemList? authorStoryList;
  final dynamic error;
  const AuthorStoryListState._({
    required this.status,
    this.authorStoryList,
    this.error,
  });

  const AuthorStoryListState.initial()
      : this._(status: AuthorStoryListStatus.initial);

  const AuthorStoryListState.loading()
      : this._(status: AuthorStoryListStatus.loading);

  const AuthorStoryListState.loaded({
    required StoryListItemList authorStoryList,
  }) : this._(
          status: AuthorStoryListStatus.loaded,
          authorStoryList: authorStoryList,
        );

  const AuthorStoryListState.loadingMore({
    required StoryListItemList authorStoryList,
  }) : this._(
          status: AuthorStoryListStatus.loadingMore,
          authorStoryList: authorStoryList,
        );

  const AuthorStoryListState.loadingMoreFail({
    required StoryListItemList authorStoryList,
  }) : this._(
          status: AuthorStoryListStatus.loadingMoreFail,
          authorStoryList: authorStoryList,
        );

  const AuthorStoryListState.error({required dynamic error})
      : this._(status: AuthorStoryListStatus.error, error: error);

  @override
  List<Object> get props => [status];
}
