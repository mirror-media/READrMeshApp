part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchNews extends NewsEvent {
  final String newsId;
  final Member member;

  const FetchNews(this.newsId, this.member);

  @override
  String toString() => 'FetchNews id=$newsId';
}
