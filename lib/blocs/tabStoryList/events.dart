abstract class TabStoryListEvents {}

class FetchStoryList extends TabStoryListEvents {
  @override
  String toString() => 'FetchStoryList';

  final bool isVideo;

  FetchStoryList({this.isVideo = false});
}

class FetchNextPage extends TabStoryListEvents {
  @override
  String toString() =>
      'FetchNextPage { loadingMorePage: 12 stories 2 projects }';
}

class FetchStoryListByCategorySlug extends TabStoryListEvents {
  final String slug;
  final bool isVideo;

  FetchStoryListByCategorySlug(this.slug, {this.isVideo = false});

  @override
  String toString() => 'FetchStoryListByCategorySlug { slug: $slug }';
}

class FetchNextPageByCategorySlug extends TabStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 14});

  @override
  String toString() =>
      'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: 12 stories 2 projects }';
}
