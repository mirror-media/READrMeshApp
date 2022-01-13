part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReloading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, dynamic> data;
  const HomeLoaded(this.data);
}

class HomeError extends HomeState {
  final dynamic error;
  const HomeError(this.error);
}

class HomeReloadFailed extends HomeState {
  final dynamic error;
  const HomeReloadFailed(this.error);
}
