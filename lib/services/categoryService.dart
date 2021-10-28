import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/storyListItemList.dart';

abstract class CategoryRepos {
  Future<CategoryList> fetchCategoryList();
  Future<StoryListItemList> fetchLastestPostByCategorySlug(String slug);
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
        sortBy: [id_ASC]
      ) {
        id
        name
        slug
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

    for (var category in categoryList) {
      StoryListItemList latestPost =
          await fetchLastestPostByCategorySlug(category.slug);
      category.latestPostTime = latestPost[0].publishTime;
    }
    categoryList.sort((a, b) => b.latestPostTime!.compareTo(a.latestPostTime!));
    CategoryList fixedCategoryList = CategoryList();
    fixedCategoryList.add(Category(id: '0', name: '最新報導', slug: 'latest'));
    fixedCategoryList.addAll(categoryList);

    return fixedCategoryList;
  }

  @override
  Future<StoryListItemList> fetchLastestPostByCategorySlug(String slug) async {
    String key = 'fetchLastestPostByCategorySlug?slug=$slug';
    String query = """
    query (
    \$where: PostWhereInput,
    \$first: Int,
    ) {
      allPosts(
        where: \$where,  
        first: \$first, 
        sortBy: [ publishTime_DESC ]
      ) {
        id
        name
        publishTime
        categories(where: {
          state: active
       }){
          id
          name
          slug
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "categories_some": {"slug": slug}
      },
      "first": 1
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {"Content-Type": "application/json"});

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);

    return newsList;
  }
}
