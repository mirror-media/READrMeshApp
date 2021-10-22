abstract class StoryEvents {}

class ChangeTextSize extends StoryEvents {
  final double textSize;
  ChangeTextSize(this.textSize);

  @override
  String toString() => "ChangeTextSize";
}

class FetchPublishedStoryBySlug extends StoryEvents {
  final String slug;
  FetchPublishedStoryBySlug(this.slug);

  @override
  String toString() => 'FetchPublishedStoryBySlug { storySlug: $slug }';
}
