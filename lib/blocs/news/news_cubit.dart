import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/services/newsStoryService.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsInitial());
  final NewsStoryService _newsStoryService = NewsStoryService();

  fetchNewsData({
    required String newsId,
    bool isNative = false,
  }) async {
    print('Fetch news data id=$newsId');
    emit(NewsLoading());
    try {
      await UserHelper.instance.fetchUserData();
      NewsStoryItem newsStoryItem =
          await _newsStoryService.fetchNewsData(newsId);
      emit(NewsLoaded(newsStoryItem));
    } catch (e) {
      emit(NewsError(determineException(e)));
    }
  }
}
