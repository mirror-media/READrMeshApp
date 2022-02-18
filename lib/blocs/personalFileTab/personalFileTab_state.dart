part of 'personalFileTab_bloc.dart';

abstract class PersonalFileTabState extends Equatable {
  const PersonalFileTabState();

  @override
  List<Object> get props => [];
}

class PersonalFileTabInitial extends PersonalFileTabState {}

class PersonalFileTabLoading extends PersonalFileTabState {}

class PersonalFileTabLoaded extends PersonalFileTabState {
  final dynamic data;
  const PersonalFileTabLoaded(this.data);
}

class PersonalFileTabError extends PersonalFileTabState {
  final dynamic error;
  const PersonalFileTabError(this.error);
}

class PersonalFileTabLoadingMore extends PersonalFileTabState {}

class PersonalFileTabLoadMoreSuccess extends PersonalFileTabState {
  final dynamic data;
  const PersonalFileTabLoadMoreSuccess(this.data);
}

class PersonalFileTabLoadMoreFailed extends PersonalFileTabState {
  final dynamic error;
  const PersonalFileTabLoadMoreFailed(this.error);
}

class PersonalFileTabReloading extends PersonalFileTabState {}

class PersonalFileTabReloadFailed extends PersonalFileTabState {
  final dynamic error;
  const PersonalFileTabReloadFailed(this.error);
}
