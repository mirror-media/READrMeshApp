import 'package:equatable/equatable.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/models/storyListItemList.dart';

enum TabStoryListStatus {
  initial,
  loading,
  loadingMore,
  loadingMoreFail,
  loaded,
  sortCategory,
  error,
}

class TabStoryListState extends Equatable {
  final TabStoryListStatus status;
  final StoryListItemList? mixedStoryList;
  final CategoryList? categoryList;
  final dynamic error;
  const TabStoryListState._({
    required this.status,
    this.mixedStoryList,
    this.categoryList,
    this.error,
  });

  const TabStoryListState.initial()
      : this._(status: TabStoryListStatus.initial);

  const TabStoryListState.loading()
      : this._(status: TabStoryListStatus.loading);

  const TabStoryListState.loaded({
    required StoryListItemList mixedStoryList,
  }) : this._(
          status: TabStoryListStatus.loaded,
          mixedStoryList: mixedStoryList,
        );

  const TabStoryListState.loadingMore({
    required StoryListItemList mixedStoryList,
  }) : this._(
          status: TabStoryListStatus.loadingMore,
          mixedStoryList: mixedStoryList,
        );

  const TabStoryListState.loadingMoreFail({
    required StoryListItemList mixedStoryList,
  }) : this._(
          status: TabStoryListStatus.loadingMoreFail,
          mixedStoryList: mixedStoryList,
        );

  const TabStoryListState.error({required dynamic error})
      : this._(status: TabStoryListStatus.error, error: error);

  @override
  List<Object> get props => [status];
}
