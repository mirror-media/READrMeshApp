import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/newsListItemList.dart';
import 'package:readr/services/homeScreenService.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeScreenService _homeScreenService = HomeScreenService();
  final NewsListItemList _newsList = NewsListItemList();

  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        if (event is LoadHomeScreen) {
          final futureList = await Future.wait([
            _homeScreenService.fetchNewsList(),
          ]);
          for (var item in futureList) {
            _newsList.addAll(item);
          }

          emit(HomeLoaded(_newsList));
        }
      } catch (e) {
        if (event is FetchMoreHomeStoryList) {
          Fluttertoast.showToast(
              msg: "加載失敗",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          await Future.delayed(const Duration(seconds: 5));
          emit(HomeLoadingMoreFailed(_newsList, e));
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
