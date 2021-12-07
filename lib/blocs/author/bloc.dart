import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/services/authorStoryListService.dart';

part 'events.dart';
part 'states.dart';

class AuthorStoryListBloc
    extends Bloc<AuthorStoryListEvents, AuthorStoryListState> {
  final AuthorStoryListRepos authorStoryListRepos = AuthorStoryListServices();
  StoryListItemList authorStoryList = StoryListItemList();

  AuthorStoryListBloc() : super(const AuthorStoryListState.initial());

  @override
  Stream<AuthorStoryListState> mapEventToState(
      AuthorStoryListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchStoryListByAuthorSlug) {
        yield const AuthorStoryListState.loading();
        authorStoryList =
            await authorStoryListRepos.fetchStoryListByAuthorSlug(event.slug);

        yield AuthorStoryListState.loaded(
          authorStoryList: authorStoryList,
        );
      } else if (event is FetchNextPageByAuthorSlug) {
        yield AuthorStoryListState.loadingMore(
          authorStoryList: authorStoryList,
        );

        StoryListItemList newStoryListItemList =
            await authorStoryListRepos.fetchStoryListByAuthorSlug(
          event.slug,
          skip: authorStoryList.length,
          withCount: false,
        );
        for (var item in authorStoryList) {
          newStoryListItemList.removeWhere((element) => element.id == item.id);
        }
        authorStoryList.addAll(newStoryListItemList);
        yield AuthorStoryListState.loaded(
          authorStoryList: authorStoryList,
        );
      }
    } catch (e) {
      if (event is FetchNextPageByAuthorSlug) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(const Duration(seconds: 5));
        yield AuthorStoryListState.loadingMoreFail(
          authorStoryList: authorStoryList,
        );
      } else if (e is SocketException) {
        yield AuthorStoryListState.error(
          error: NoInternetException('No Internet'),
        );
      } else if (e is HttpException) {
        yield AuthorStoryListState.error(
          error: NoServiceFoundException('No Service Found'),
        );
      } else if (e is FormatException) {
        yield AuthorStoryListState.error(
          error: InvalidFormatException('Invalid Response format'),
        );
      } else if (e is FetchDataException) {
        yield AuthorStoryListState.error(
          error: NoInternetException('Error During Communication'),
        );
      } else if (e is BadRequestException ||
          e is UnauthorisedException ||
          e is InvalidInputException) {
        yield AuthorStoryListState.error(
          error: Error400Exception('Unauthorised'),
        );
      } else if (e is InternalServerErrorException) {
        yield AuthorStoryListState.error(
          error: Error500Exception('Internal Server Error'),
        );
      } else {
        yield AuthorStoryListState.error(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
