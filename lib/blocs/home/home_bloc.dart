import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/homeScreenService.dart';
import 'package:readr/services/memberService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeScreenService _homeScreenService = HomeScreenService();
  final MemberService _memberService = MemberService();

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
          emit(HomeLoaded(
            data: data,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
          ));
        } else if (event is ReloadHomeScreen) {
          emit(HomeReloading());
          Map<String, dynamic> data =
              await _homeScreenService.fetchHomeScreenData();
          final prefs = await SharedPreferences.getInstance();
          bool showPaywall = prefs.getBool('showPaywall') ?? true;
          bool showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
          emit(HomeLoaded(
            data: data,
            showFullScreenAd: showFullScreenAd,
            showPaywall: showPaywall,
          ));
        } else if (event is UpdateFollowingMember) {
          List<Member>? newFollowingMembers = event.currentMember.following;
          if (newFollowingMembers != null) {
            if (event.isFollowed) {
              newFollowingMembers.remove(event.targetMember);
            } else {
              newFollowingMembers.add(event.targetMember);
            }
          } else {
            newFollowingMembers = [event.targetMember];
          }

          emit(UpdatingFollowing(newFollowingMembers, event.isFollowed));

          if (event.isFollowed) {
            newFollowingMembers = await _memberService.removeFollowingMember(
                event.currentMember.memberId, event.targetMember.memberId);
          } else {
            newFollowingMembers = await _memberService.addFollowingMember(
                event.currentMember.memberId, event.targetMember.memberId);
          }
          if (newFollowingMembers == null) {
            emit(UpdateFollowingFailed('Unknown error', event.isFollowed));
          } else {
            emit(UpdateFollowingSuccess());
          }
        } else if (event is LoadMoreFollowingPicked) {
          emit(LoadingMoreFollowingPicked());

          List<NewsListItem> newFollowingStories =
              await _homeScreenService.fetchMoreFollowingStories(
            event.lastPickTime,
            event.alreadyFetchIds,
            event.currentMember,
          );

          emit(LoadMoreFollowingPickedSuccess(newFollowingStories));
        } else if (event is LoadMoreLatestNews) {
          emit(LoadingMoreNews());

          List<NewsListItem> newLatestNews =
              await _homeScreenService.fetchMoreLatestNews(
            event.lastPublishTime,
            event.currentMember,
          );

          emit(LoadMoreNewsSuccess(newLatestNews));
        }
      } catch (e) {
        if (event is ReloadHomeScreen) {
          emit(HomeReloadFailed(e));
        } else if (event is LoadMoreFollowingPicked) {
          emit(LoadMoreFollowingPickedFailed(e));
        } else if (event is UpdateFollowingMember) {
          emit(UpdateFollowingFailed(e, event.isFollowed));
        } else if (event is LoadMoreLatestNews) {
          emit(LoadMoreNewsFailed(e));
        } else if (e is SocketException) {
          emit(HomeError(NoInternetException('No Internet')));
        } else if (e is HttpException) {
          emit(HomeError(NoServiceFoundException('No Service Found')));
        } else if (e is FormatException) {
          emit(HomeError(InvalidFormatException('Invalid Response format')));
        } else if (e is FetchDataException) {
          emit(HomeError(NoInternetException('Error During Communication')));
        } else if (e is BadRequestException ||
            e is UnauthorisedException ||
            e is InvalidInputException) {
          emit(HomeError(Error400Exception('Unauthorised')));
        } else if (e is InternalServerErrorException) {
          emit(HomeError(Error500Exception('Internal Server Error')));
        } else {
          emit(HomeError(UnknownException(e.toString())));
        }
      }
    });
  }
}
