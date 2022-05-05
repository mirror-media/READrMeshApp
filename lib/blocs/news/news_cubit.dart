import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/story.dart';
import 'package:readr/services/newsStoryService.dart';
import 'package:readr/services/storyService.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsStoryRepos newsStoryRepos;
  final StoryRepos storyRepos;
  NewsCubit({required this.newsStoryRepos, required this.storyRepos})
      : super(NewsInitial());

  fetchNewsData({
    required String newsId,
  }) async {
    print('Fetch news data id=$newsId');
    emit(NewsLoading());
    try {
      await Get.find<UserService>().fetchUserData();
      NewsStoryItem newsStoryItem = await newsStoryRepos.fetchNewsData(newsId);
      emit(NewsLoaded(newsStoryItem));
    } catch (e) {
      emit(NewsError(determineException(e)));
    }
  }

  fetchNewsAndReadrData({required String newsId}) async {
    print('Fetch news data id=$newsId');
    emit(NewsLoading());
    try {
      await Get.find<UserService>().fetchUserData();
      NewsStoryItem newsStoryItem = await newsStoryRepos.fetchNewsData(newsId);
      if (newsStoryItem.content == null || newsStoryItem.content!.isEmpty) {
        emit(NewsError(determineException('No content error')));
      } else {
        Story story =
            await storyRepos.fetchPublishedStoryById(newsStoryItem.content!);
        emit(ReadrStoryLoaded(newsStoryItem, story));
      }
    } catch (e) {
      emit(NewsError(determineException(e)));
    }
  }
}
