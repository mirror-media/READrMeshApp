part of 'bloc.dart';

abstract class TagStoryListEvents {}

class FetchStoryListByTagSlug extends TagStoryListEvents {
  final String slug;

  FetchStoryListByTagSlug(this.slug);

  @override
  String toString() => 'FetchStoryListByTagSlug { TagSlug: $slug }';
}

class FetchNextPageByTagSlug extends TagStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByTagSlug(this.slug, {this.loadingMorePage = 10});

  @override
  String toString() =>
      'FetchNextPageByTagSlug { TagSlug: $slug, loadingMorePage: $loadingMorePage stories}';
}
