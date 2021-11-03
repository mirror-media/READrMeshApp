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

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(const TabStoryListState.initial());

  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    print(event.toString());
    try {
      yield const TabStoryListState.loading();
      if (event is FetchStoryList) {
        StoryListItemList storyListItemList =
            await tabStoryListRepos.fetchStoryList();
        StoryListItemList projectList =
            await tabStoryListRepos.fetchProjectList();
        mixedStoryList = _mixTwoList(
            storyListItemList: storyListItemList, projectList: projectList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchNextPage) {
        yield TabStoryListState.loadingMore(
          mixedStoryList: mixedStoryList,
        );
        StoryListItemList newStoryListItemList =
            await tabStoryListRepos.fetchNextPage();
        StoryListItemList newprojectList =
            await tabStoryListRepos.fetchProjectListNextPage();
        StoryListItemList newMixedList = _mixTwoList(
            storyListItemList: newStoryListItemList,
            projectList: newprojectList,
            loadMore: true);
        mixedStoryList.addAll(newMixedList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchStoryListByCategorySlug) {
        StoryListItemList storyListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        StoryListItemList projectList =
            await tabStoryListRepos.fetchProjectListByCategorySlug(event.slug);
        mixedStoryList = _mixTwoList(
            storyListItemList: storyListItemList, projectList: projectList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchNextPageByCategorySlug) {
        yield TabStoryListState.loadingMore(
          mixedStoryList: mixedStoryList,
        );
        StoryListItemList newStoryListItemList =
            await tabStoryListRepos.fetchNextPageByCategorySlug(event.slug);
        StoryListItemList newprojectList = await tabStoryListRepos
            .fetchProjectListNextPageByCategorySlug(event.slug);
        StoryListItemList newMixedList = _mixTwoList(
            storyListItemList: newStoryListItemList,
            projectList: newprojectList,
            loadMore: true);
        mixedStoryList.addAll(newMixedList);
        yield TabStoryListState.loaded(
          mixedStoryList: mixedStoryList,
        );
      }
    } on SocketException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      if (event is FetchNextPage || event is FetchNextPageByCategorySlug) {
        tabStoryListRepos.reduceSkip();
      }
      yield TabStoryListState.error(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      if (event is FetchNextPage) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(const Duration(seconds: 5));
        tabStoryListRepos.reduceSkip();
        yield TabStoryListState.loadingMoreFail(
          mixedStoryList: mixedStoryList,
        );
      } else if (event is FetchNextPageByCategorySlug) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(const Duration(seconds: 5));
        tabStoryListRepos.reduceSkip();
        yield TabStoryListState.loadingMoreFail(
          mixedStoryList: mixedStoryList,
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
