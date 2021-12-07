import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/tabStoryList/events.dart';
import 'package:readr/blocs/tabStoryList/states.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/services/tabStoryListService.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvents, TabStoryListState> {
  final TabStoryListRepos tabStoryListRepos;
  StoryListItemList mixedStoryList = StoryListItemList();
  StoryListItemList storyListItemList = StoryListItemList();
  StoryListItemList projectList = StoryListItemList();

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(const TabStoryListState.initial());

  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchStoryList) {
        yield const TabStoryListState.loading();
        List<StoryListItemList> futureList =
            await tabStoryListRepos.fetchStoryList();
        storyListItemList = futureList[0];
        projectList = futureList[1];
        mixedStoryList = _mixTwoList(
            storyListItemList: storyListItemList, projectList: projectList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchNextPage) {
        yield TabStoryListState.loadingMore(
          mixedStoryList: mixedStoryList,
        );
        List<StoryListItemList> futureList =
            await tabStoryListRepos.fetchStoryList(
          storySkip: storyListItemList.length,
          storyFirst: 12,
          projectSkip: projectList.length,
          withCount: false,
        );
        StoryListItemList newStoryListItemList = futureList[0];
        StoryListItemList newprojectList = futureList[1];
        for (var item in storyListItemList) {
          newStoryListItemList.removeWhere((element) => element.id == item.id);
        }
        for (var item in projectList) {
          newprojectList.removeWhere((element) => element.id == item.id);
        }
        StoryListItemList newMixedList = _mixTwoList(
          storyListItemList: newStoryListItemList,
          projectList: newprojectList,
          loadMore: true,
        );
        storyListItemList.addAll(newStoryListItemList);
        projectList.addAll(newprojectList);
        mixedStoryList.addAll(newMixedList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchStoryListByCategorySlug) {
        yield const TabStoryListState.loading();
        List<StoryListItemList> futureList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        storyListItemList = futureList[0];
        projectList = futureList[1];
        mixedStoryList = _mixTwoList(
            storyListItemList: storyListItemList, projectList: projectList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchNextPageByCategorySlug) {
        yield TabStoryListState.loadingMore(
          mixedStoryList: mixedStoryList,
        );
        List<StoryListItemList> futureList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(
          event.slug,
          storySkip: storyListItemList.length,
          storyFirst: 12,
          projectSkip: projectList.length,
          withCount: false,
        );
        StoryListItemList newStoryListItemList = futureList[0];
        StoryListItemList newprojectList = futureList[1];
        for (var item in storyListItemList) {
          newStoryListItemList.removeWhere((element) => element.id == item.id);
        }
        for (var item in projectList) {
          newprojectList.removeWhere((element) => element.id == item.id);
        }
        StoryListItemList newMixedList = _mixTwoList(
          storyListItemList: newStoryListItemList,
          projectList: newprojectList,
          loadMore: true,
        );
        storyListItemList.addAll(newStoryListItemList);
        projectList.addAll(newprojectList);
        mixedStoryList.addAll(newMixedList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      }
    } catch (e) {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(const Duration(seconds: 5));
        yield TabStoryListState.loadingMoreFail(
          mixedStoryList: mixedStoryList,
        );
      } else if (e is SocketException) {
        yield TabStoryListState.error(
          error: NoInternetException('No Internet'),
        );
      } else if (e is HttpException) {
        yield TabStoryListState.error(
          error: NoServiceFoundException('No Service Found'),
        );
      } else if (e is FormatException) {
        yield TabStoryListState.error(
          error: InvalidFormatException('Invalid Response format'),
        );
      } else if (e is FetchDataException) {
        yield TabStoryListState.error(
          error: NoInternetException('Error During Communication'),
        );
      } else if (e is BadRequestException ||
          e is UnauthorisedException ||
          e is InvalidInputException) {
        yield TabStoryListState.error(
          error: Error400Exception('Unauthorised'),
        );
      } else if (e is InternalServerErrorException) {
        yield TabStoryListState.error(
          error: Error500Exception('Internal Server Error'),
        );
      } else {
        yield TabStoryListState.error(
          error: UnknownException(e.toString()),
        );
      }
    }
  }

  StoryListItemList _mixTwoList({
    required StoryListItemList storyListItemList,
    required StoryListItemList projectList,
    bool loadMore = false,
  }) {
    StoryListItemList tempMixedList = StoryListItemList();
    tempMixedList.addAll(storyListItemList);
    if (tempMixedList.isEmpty) {
      tempMixedList = projectList;
    } else {
      int pointer = loadMore ? 0 : 6;
      for (int i = 0; i < projectList.length; i++) {
        if (pointer < tempMixedList.length) {
          tempMixedList.insert(pointer, projectList[i]);
          pointer = pointer + 7;
        } else {
          tempMixedList.add(projectList[i]);
        }
      }
    }
    tempMixedList.allStoryCount =
        storyListItemList.allStoryCount + projectList.allStoryCount;
    return tempMixedList;
  }
}
