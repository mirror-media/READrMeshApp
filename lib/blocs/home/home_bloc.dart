import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/homeScreenService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeScreenRepos homeScreenRepos;
  late final StreamSubscription followButtonCubitSubscription;

  HomeBloc({required this.homeScreenRepos}) : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      try {
        print(event.toString());
        if (event is InitialHomeScreen) {
          emit(HomeLoading());
          Map<String, dynamic> data =
              await homeScreenRepos.fetchHomeScreenData();
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
          if (Get.find<UserService>().isMember) {
            final List<String> followingPublisherIds =
                prefs.getStringList('followingPublisherIds') ?? [];
            if (followingPublisherIds.isNotEmpty) {
              showSyncToast = true;
              await prefs.setStringList('followingPublisherIds', []);
            }
            await Get.find<UserService>().checkInvitationCode();
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
        }

        if (event is ReloadHomeScreen) {
          emit(HomeReloading());
          Map<String, dynamic> data =
              await homeScreenRepos.fetchHomeScreenData();
          final prefs = await SharedPreferences.getInstance();
          bool showPaywall = prefs.getBool('showPaywall') ?? true;
          bool showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
          await Get.find<UserService>().fetchUserData();
          List<MemberFollowableItem> recommendedMembers = [];
          List<PublisherFollowableItem> recommendedPublishers = [];
          for (var member in data['recommendedMembers']) {
            recommendedMembers.add(MemberFollowableItem(member));
          }
          for (var publisher in data['recommendedPublishers']) {
            recommendedPublishers.add(PublisherFollowableItem(publisher));
          }

          if (Get.find<UserService>().isMember) {
            await Get.find<UserService>().checkInvitationCode();
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
        }

        if (event is LoadMoreFollowingPicked) {
          emit(LoadingMoreFollowingPicked());

          List<NewsListItem> newFollowingStories =
              await homeScreenRepos.fetchMoreFollowingStories(
            event.alreadyFetchIds,
          );

          emit(LoadMoreFollowingPickedSuccess(newFollowingStories));
        }

        if (event is LoadMoreLatestNews) {
          emit(LoadingMoreNews());

          List<NewsListItem> newLatestNews =
              await homeScreenRepos.fetchMoreLatestNews(
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
