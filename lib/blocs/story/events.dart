abstract class StoryEvents {}

class ChangeTextSize extends StoryEvents {
  final double textSize;
  ChangeTextSize(this.textSize);

  @override
  String toString() => "ChangeTextSize";
}

class FetchPublishedStoryById extends StoryEvents {
  final String id;
  FetchPublishedStoryById(this.id);

  @override
  String toString() => 'FetchPublishedStoryById { storyId: $id }';
}
