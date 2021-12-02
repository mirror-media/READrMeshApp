part of 'bloc.dart';

abstract class AuthorStoryListEvents {}

class FetchStoryListByAuthorSlug extends AuthorStoryListEvents {
  final String slug;

  FetchStoryListByAuthorSlug(this.slug);

  @override
  String toString() => 'FetchStoryListByAuthorSlug { AuthorSlug: $slug }';
}

class FetchNextPageByAuthorSlug extends AuthorStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByAuthorSlug(this.slug, {this.loadingMorePage = 10});

  @override
  String toString() =>
      'FetchNextPageByAuthorSlug { AuthorSlug: $slug, loadingMorePage: $loadingMorePage stories}';
}
