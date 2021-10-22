abstract class TabStoryListEvents {}

class FetchStoryList extends TabStoryListEvents {
  @override
  String toString() => 'FetchStoryList';

  final bool isVideo;

  FetchStoryList({this.isVideo = false});
}

class FetchNextPage extends TabStoryListEvents {
  final int loadingMorePage;

  FetchNextPage({this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPage { loadingMorePage: $loadingMorePage }';
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

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 20});

  @override
  String toString() =>
      'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: $loadingMorePage }';
}

class FetchPopularStoryList extends TabStoryListEvents {
  bool isVideo;
  FetchPopularStoryList({this.isVideo = false});

  @override
  String toString() => 'FetchPopularStoryList';
}
