part of 'news_cubit.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final NewsStoryItem newsStoryItem;
  const NewsLoaded(this.newsStoryItem);
}

class NewsError extends NewsState {
  final dynamic error;
  const NewsError(this.error);
}
