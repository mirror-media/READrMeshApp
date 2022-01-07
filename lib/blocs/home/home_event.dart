part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchHomeStoryList extends HomeEvent {}

class FetchMoreHomeStoryList extends HomeEvent {}
