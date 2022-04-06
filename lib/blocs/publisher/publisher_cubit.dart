import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/publisherService.dart';

part 'publisher_state.dart';

class PublisherCubit extends Cubit<PublisherState> {
  final PublisherRepos publisherRepos;
  PublisherCubit({required this.publisherRepos}) : super(PublisherInitial());
  int _followerCount = 0;

  fetchPublisherNews(String publisherId) async {
    try {
      emit(PublisherLoading());
      var futureList = await Future.wait([
        publisherRepos.fetchPublisherNews(publisherId, DateTime.now()),
        publisherRepos.fetchPublisherFollowerCount(publisherId),
      ]);
      _followerCount = futureList[1] as int;
      emit(
          PublisherLoaded(futureList[0] as List<NewsListItem>, _followerCount));
    } catch (e) {
      emit(PublisherError(determineException(e)));
    }
  }

  fetchMorePublisherNews(String publisherId, DateTime filter) async {
    try {
      emit(PublisherLoadingMore());
      emit(PublisherLoaded(
        await publisherRepos.fetchPublisherNews(publisherId, filter),
        _followerCount,
      ));
    } catch (e) {
      emit(PublisherLoadMoreFailed(determineException(e)));
    }
  }
}
