import 'package:readr/models/categoryList.dart';
import 'package:equatable/equatable.dart';

enum CategoriesStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final CategoryList? categoryList;
  final dynamic error;
  const CategoriesState._({
    required this.status,
    this.categoryList,
    this.error = '',
  });

  const CategoriesState.initial() : this._(status: CategoriesStatus.initial);

  const CategoriesState.loading() : this._(status: CategoriesStatus.loading);

  const CategoriesState.loaded({required CategoryList categoryList})
      : this._(
          status: CategoriesStatus.loaded,
          categoryList: categoryList,
        );

  const CategoriesState.error({required dynamic error})
      : this._(status: CategoriesStatus.error, error: error);

  @override
  List<Object> get props => [status];
}
