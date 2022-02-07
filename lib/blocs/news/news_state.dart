part of 'news_bloc.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final NewsStoryItem newsStoryItem;
  final Member member;
  const NewsLoaded(this.newsStoryItem, this.member);
}

class NewsError extends NewsState {
  final dynamic error;
  const NewsError(this.error);
}
