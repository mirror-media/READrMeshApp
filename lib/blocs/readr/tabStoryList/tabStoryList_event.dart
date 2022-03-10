part of 'tabStoryList_bloc.dart';

abstract class TabStoryListEvent extends Equatable {
  const TabStoryListEvent();

  @override
  List<Object> get props => [];
}

class FetchStoryList extends TabStoryListEvent {
  @override
  String toString() => 'FetchStoryList';
}

class FetchNextPage extends TabStoryListEvent {
  @override
  String toString() =>
      'FetchNextPage { loadingMorePage: 12 stories 2 projects }';
}

class FetchStoryListByCategorySlug extends TabStoryListEvent {
  final String slug;

  const FetchStoryListByCategorySlug(this.slug);

  @override
  String toString() => 'FetchStoryListByCategorySlug { slug: $slug }';
}

class FetchNextPageByCategorySlug extends TabStoryListEvent {
  final String slug;

  const FetchNextPageByCategorySlug(
    this.slug,
  );

  @override
  String toString() =>
      'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: 12 stories 2 projects }';
}
