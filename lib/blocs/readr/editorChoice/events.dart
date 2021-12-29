import 'package:readr/models/storyListItemList.dart';

abstract class EditorChoiceEvents {}

class TabStoryListIsLoaded extends EditorChoiceEvents {
  final StoryListItemList storyListItemList;
  TabStoryListIsLoaded(this.storyListItemList);
}

class FetchEditorChoiceList extends EditorChoiceEvents {}
