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
  StoryListItemList storyListItemList = StoryListItemList();

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(TabStoryListInitState());

  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    print(event.toString());
    try {
      yield TabStoryListLoading();
      if (event is FetchStoryList) {
        storyListItemList = await tabStoryListRepos.fetchStoryList();
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if (event is FetchNextPage) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList = await tabStoryListRepos
            .fetchNextPage(loadingMorePage: event.loadingMorePage);
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if (event is FetchStoryListByCategorySlug) {
        storyListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if (event is FetchNextPageByCategorySlug) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList =
            await tabStoryListRepos.fetchNextPageByCategorySlug(event.slug,
                loadingMorePage: event.loadingMorePage);
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      }
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
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
        tabStoryListRepos.reduceSkip(event.loadingMorePage);
        yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
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
        tabStoryListRepos.reduceSkip(event.loadingMorePage);
        yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
      } else {
        yield TabStoryListError(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
