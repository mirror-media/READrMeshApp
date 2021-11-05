import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class CategoryRepos {
  Future<CategoryList> fetchCategoryList();
}

class CategoryServices implements CategoryRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<CategoryList> fetchCategoryList() async {
    const key = 'fetchCategoryList';

    String query = """
    query(
      \$where: CategoryWhereInput){
      allCategories(
        where: \$where, 
      ) {
        id
        name
        slug
        relatedPost(sortBy: [ publishTime_DESC ], first: 1){
          publishTime
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"state": "active"}
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: categoryCacheDuration,
        headers: {"Content-Type": "application/json"});

    CategoryList categoryList =
        CategoryList.fromJson(jsonResponse['data']['allCategories']);

    categoryList.sort((a, b) => b.latestPostTime!.compareTo(a.latestPostTime!));
    CategoryList fixedCategoryList = CategoryList();
    fixedCategoryList.add(Category(
      id: '0',
      name: '最新報導',
      slug: 'latest',
    ));
    fixedCategoryList.addAll(categoryList);

    return fixedCategoryList;
  }
}
