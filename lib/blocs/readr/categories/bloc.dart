// event, state => new state => update UI.

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/categories/events.dart';
import 'package:readr/blocs/readr/categories/states.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/services/categoryService.dart';

class CategoriesBloc extends Bloc<CategoriesEvents, CategoriesState> {
  final CategoryRepos categoryRepos;
  CategoryList categoryList = CategoryList();

  CategoriesBloc({required this.categoryRepos})
      : super(const CategoriesState.initial());

  @override
  Stream<CategoriesState> mapEventToState(CategoriesEvents event) async* {
    print(event.toString());
    try {
      yield const CategoriesState.loading();
      if (event is FetchCategories) {
        CategoryList categoryList = await categoryRepos.fetchCategoryList();
        yield CategoriesState.loaded(categoryList: categoryList);
      }
    } on SocketException {
      yield CategoriesState.error(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield CategoriesState.error(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield CategoriesState.error(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield CategoriesState.error(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield CategoriesState.error(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield CategoriesState.error(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield CategoriesState.error(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield CategoriesState.error(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield CategoriesState.error(
        error: UnknownException(e.toString()),
      );
    }
  }
}
