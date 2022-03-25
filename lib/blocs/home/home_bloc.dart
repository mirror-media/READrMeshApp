import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/homeScreenService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeScreenService _homeScreenService = HomeScreenService();
  final FollowButtonCubit followButtonCubit;
  late final StreamSubscription followButtonCubitSubscription;

  HomeBloc(this.followButtonCubit) : super(HomeInitial()) {
    followButtonCubitSubscription = followButtonCubit.stream.listen((state) {
      if (state is FollowButtonUpdated) {
        EasyDebounce.debounce(
          'followingUpdate',
          const Duration(seconds: 1),
          () => add(ReloadHomeScreen()),
        );
      }
    });

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
          List<MemberFollowableItem> recommendedMembers = [];
          List<PublisherFollowableItem> recommendedPublishers = [];
          for (var member in data['recommendedMembers']) {
            recommendedMembers.add(MemberFollowableItem(member));
          }
          for (var publisher in data['recommendedPublishers']) {
            recommendedPublishers.add(PublisherFollowableItem(publisher));
          }
          bool showSyncToast = false;
          if (UserHelper.instance.isMember) {
            final List<String> followingPublisherIds =
                prefs.getStringList('followingPublisherIds') ?? [];
            if (followingPublisherIds.isNotEmpty) {
              showSyncToast = true;
              await prefs.setStringList('followingPublisherIds', []);
            }
          }
          emit(HomeLoaded(
            allLatestNews: data['allLatestNews'],
            followingStories: data['followingStories'],
            latestComments: data['latestComments'],
            recommendedMembers: recommendedMembers,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
            recommendedPublishers: recommendedPublishers,
            showSyncToast: showSyncToast,
          ));
        } else if (event is ReloadHomeScreen) {
          emit(HomeReloading());
          Map<String, dynamic> data =
              await _homeScreenService.fetchHomeScreenData();
          final prefs = await SharedPreferences.getInstance();
          bool showPaywall = prefs.getBool('showPaywall') ?? true;
          bool showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
          await UserHelper.instance.fetchUserData();
          List<MemberFollowableItem> recommendedMembers = [];
          List<PublisherFollowableItem> recommendedPublishers = [];
          for (var member in data['recommendedMembers']) {
            recommendedMembers.add(MemberFollowableItem(member));
          }
          for (var publisher in data['recommendedPublishers']) {
            recommendedPublishers.add(PublisherFollowableItem(publisher));
          }
          emit(HomeLoaded(
            allLatestNews: data['allLatestNews'],
            followingStories: data['followingStories'],
            latestComments: data['latestComments'],
            recommendedMembers: recommendedMembers,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
            recommendedPublishers: recommendedPublishers,
          ));
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
        }
      } catch (e) {
        if (event is ReloadHomeScreen) {
          emit(HomeReloadFailed(e));
        } else if (event is LoadMoreFollowingPicked) {
          emit(LoadMoreFollowingPickedFailed(e));
        } else if (event is LoadMoreLatestNews) {
          emit(LoadMoreNewsFailed(e));
        } else {
          emit(HomeError(determineException(e)));
        }
      }
    });
  }
}
