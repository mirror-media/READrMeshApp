import 'package:readr/models/story.dart';

abstract class StoryState {}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  final double textSize;
  StoryLoaded({required this.story, required this.textSize});
}

class TextSizeChanged extends StoryState {
  final double textSize;
  TextSizeChanged({required this.textSize});
}

class StoryError extends StoryState {
  final dynamic error;
  StoryError({this.error});
}
