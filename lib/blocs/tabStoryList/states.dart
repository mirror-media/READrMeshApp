import 'package:readr/models/storyListItemList.dart';

abstract class TabStoryListState {}

class TabStoryListInitState extends TabStoryListState {}

class TabStoryListLoading extends TabStoryListState {}

class TabStoryListLoadingMore extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoadingMore({required this.storyListItemList});
}

class TabStoryListLoadingMoreFail extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoadingMoreFail({required this.storyListItemList});
}

class TabStoryListLoaded extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoaded({required this.storyListItemList});
}

class TabStoryListError extends TabStoryListState {
  final dynamic error;
  TabStoryListError({this.error});
}
