class CommentCountHelper {
  CommentCountHelper._internal();

  factory CommentCountHelper() => _instance;

  static late final CommentCountHelper _instance =
      CommentCountHelper._internal();

  static CommentCountHelper get instance => _instance;

  final Map<String, int> _storyMap = {};

  int getStoryCommentCount(String storyId) {
    return _storyMap[storyId] ?? 0;
  }

  void updateStoryMap(String storyId, int storyCommentCount) {
    _storyMap.update(
      storyId,
      (value) => storyCommentCount,
      ifAbsent: () => storyCommentCount,
    );
  }
}
