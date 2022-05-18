import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/categories/events.dart';
import 'package:readr/blocs/readr/categories/states.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/services/categoryService.dart';

class CategoriesBloc extends Bloc<CategoriesEvents, CategoriesState> {
  final CategoryRepos categoryRepos;
  CategoryList categoryList = CategoryList();

  CategoriesBloc({required this.categoryRepos})
      : super(const CategoriesState.initial()) {
    on<FetchCategories>(
      (event, emit) async {
        print(event.toString());
        try {
          emit(const CategoriesState.loading());
          CategoryList categoryList = await categoryRepos.fetchCategoryList();
          emit(CategoriesState.loaded(categoryList: categoryList));
        } catch (e) {
          emit(CategoriesState.error(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
