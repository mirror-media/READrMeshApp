part of 'tabStoryList_bloc.dart';

abstract class TabStoryListState extends Equatable {
  const TabStoryListState();

  @override
  List<Object> get props => [];
}

class TabStoryListInitial extends TabStoryListState {}

class TabStoryListLoading extends TabStoryListState {}

class TabStoryListLoaded extends TabStoryListState {
  final List<ReadrListItem> mixedList;
  final bool noMore;
  const TabStoryListLoaded(this.mixedList, this.noMore);
}

class TabStoryListError extends TabStoryListState {
  final dynamic error;
  const TabStoryListError(this.error);
}

class TabStoryListLoadingMore extends TabStoryListState {}

class TabStoryListLoadingMoreFailed extends TabStoryListState {
  final dynamic error;
  const TabStoryListLoadingMoreFailed(this.error);
}
