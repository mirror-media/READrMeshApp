import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/homeScreenService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeScreenService _homeScreenService = HomeScreenService();
  List<MemberFollowableItem> _recommendedMembers = [];
  List<PublisherFollowableItem> _recommendedPublishers = [];

  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      try {
        print(event.toString());
        if (event is InitialHomeScreen) {
          emit(HomeLoading());
          Map<String, dynamic> data =
              await _homeScreenService.fetchHomeScreenData();
          final prefs = await SharedPreferences.getInstance();
          bool showPaywall = prefs.getBool('showPaywall') ?? true;
          bool showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
          for (var member in data['recommendedMembers']) {
            _recommendedMembers.add(MemberFollowableItem(member));
          }
          for (var publisher in data['recommendedPublishers']) {
            _recommendedPublishers.add(PublisherFollowableItem(publisher));
          }
          emit(HomeLoaded(
            allLatestNews: data['allLatestNews'],
            followingStories: data['followingStories'],
            latestComments: data['latestComments'],
            recommendedMembers: _recommendedMembers,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
            recommendedPublishers: _recommendedPublishers,
          ));
        } else if (event is ReloadHomeScreen) {
          emit(HomeReloading());
          Map<String, dynamic> data =
              await _homeScreenService.fetchHomeScreenData();
          final prefs = await SharedPreferences.getInstance();
          bool showPaywall = prefs.getBool('showPaywall') ?? true;
          bool showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
          await UserHelper.instance.fetchUserData();
          _recommendedMembers = [];
          _recommendedPublishers = [];
          for (var member in data['recommendedMembers']) {
            _recommendedMembers.add(MemberFollowableItem(member));
          }
          for (var publisher in data['recommendedPublishers']) {
            _recommendedPublishers.add(PublisherFollowableItem(publisher));
          }
          emit(HomeLoaded(
            allLatestNews: data['allLatestNews'],
            followingStories: data['followingStories'],
            latestComments: data['latestComments'],
            recommendedMembers: _recommendedMembers,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
            recommendedPublishers: _recommendedPublishers,
          ));
        } else if (event is UpdateFollowingMember) {
          emit(UpdatingFollowing());
          int itemIndex = _recommendedMembers
              .indexWhere((element) => element.id == event.memberId);
          if (itemIndex != -1) {
            _recommendedMembers[itemIndex].isFollowing = event.isFollowing;
          }
          emit(UpdateRecommendedMembers(_recommendedMembers));
        } else if (event is UpdateFollowingPublisher) {
          emit(UpdatingFollowing());
          int itemIndex = _recommendedPublishers
              .indexWhere((element) => element.id == event.memberId);
          if (itemIndex != -1) {
            _recommendedPublishers[itemIndex].isFollowing = event.isFollowing;
          }
          emit(UpdateRecommendedPublishers(_recommendedPublishers));
        } else if (event is LoadMoreFollowingPicked) {
          emit(LoadingMoreFollowingPicked());

          List<NewsListItem> newFollowingStories =
              await _homeScreenService.fetchMoreFollowingStories(
            event.lastPickTime,
            event.alreadyFetchIds,
          );

          emit(LoadMoreFollowingPickedSuccess(newFollowingStories));
        } else if (event is LoadMoreLatestNews) {
          emit(LoadingMoreNews());

          List<NewsListItem> newLatestNews =
              await _homeScreenService.fetchMoreLatestNews(
            event.lastPublishTime,
          );

          emit(LoadMoreNewsSuccess(newLatestNews));
        } else if (event is RefreshHomeScreen) {
          emit(HomeRefreshing());
          emit(HomeRefresh());
        }
      } catch (e) {
        if (event is ReloadHomeScreen) {
          emit(HomeReloadFailed(e));
        } else if (event is LoadMoreFollowingPicked) {
          emit(LoadMoreFollowingPickedFailed(e));
        } else if (event is UpdateFollowingMember ||
            event is UpdateFollowingPublisher) {
          emit(UpdateFollowingFailed(e));
        } else if (event is LoadMoreLatestNews) {
          emit(LoadMoreNewsFailed(e));
        } else {
          emit(HomeError(determineException(e)));
        }
      }
    });
  }
}
