part of 'followerList_cubit.dart';

abstract class FollowerListState extends Equatable {
  const FollowerListState();

  @override
  List<Object> get props => [];
}

class FollowerListInitial extends FollowerListState {}

class FollowerListLoading extends FollowerListState {}

class FollowerListLoadingMore extends FollowerListState {}

class FollowerListLoaded extends FollowerListState {
  final List<Member> followerList;
  const FollowerListLoaded(this.followerList);
}

class FollowerListLoadMoreSuccess extends FollowerListState {
  final List<Member> followerList;
  const FollowerListLoadMoreSuccess(this.followerList);
}

class FollowerListLoadMoreFailed extends FollowerListState {
  final dynamic error;
  const FollowerListLoadMoreFailed(this.error);
}

class FollowerListError extends FollowerListState {
  final dynamic error;
  const FollowerListError(this.error);
}
