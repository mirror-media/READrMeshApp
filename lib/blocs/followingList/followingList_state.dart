part of 'followingList_cubit.dart';

abstract class FollowingListState extends Equatable {
  const FollowingListState();

  @override
  List<Object> get props => [];
}

class FollowingListInitial extends FollowingListState {}

class FollowingListLoading extends FollowingListState {}

class FollowingListLoadingMore extends FollowingListState {}

class FollowingListLoaded extends FollowingListState {
  final List<Member> followingMemberList;
  final List<Publisher> followPublisherList;
  final int followingMemberCount;
  const FollowingListLoaded({
    required this.followingMemberList,
    required this.followPublisherList,
    required this.followingMemberCount,
  });
}

class FollowingListLoadMoreSuccess extends FollowingListState {
  final List<Member> followingMemberList;
  const FollowingListLoadMoreSuccess(this.followingMemberList);
}

class FollowingListLoadMoreFailed extends FollowingListState {
  final dynamic error;
  const FollowingListLoadMoreFailed(this.error);
}

class FollowingListError extends FollowingListState {
  final dynamic error;
  const FollowingListError(this.error);
}
