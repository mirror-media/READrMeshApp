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

class PersonalFileTabLoadingMoreSuccess extends PersonalFileTabState {
  final dynamic data;
  const PersonalFileTabLoadingMoreSuccess(this.data);
}

class PersonalFileTabLoadingMoreFailed extends PersonalFileTabState {
  final dynamic error;
  const PersonalFileTabLoadingMoreFailed(this.error);
}

class PersonalFileTabReloading extends PersonalFileTabState {}

class PersonalFileTabReloadFailed extends PersonalFileTabState {
  final dynamic error;
  const PersonalFileTabReloadFailed(this.error);
}
