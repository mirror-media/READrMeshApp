import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class CategoryRepos {
  Future<List<Category>> fetchCategoryList();
}

class CategoryServices implements CategoryRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Category>> fetchCategoryList() async {
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
        relatedPost(
          where:{
            state: published
          }
          sortBy: [ publishTime_DESC ], 
          first: 1
        ){
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
        key,
        Get.find<EnvironmentService>().config.readrApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: categoryCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<Category> categoryList = List<Category>.from(jsonResponse['data']
            ['allCategories']
        .map((item) => Category.fromJson(item)));

    categoryList.sort((a, b) => b.latestPostTime!.compareTo(a.latestPostTime!));
    categoryList.insert(
        0,
        Category(
          id: '0',
          name: '最新文章',
          slug: 'latest',
        ));

    return categoryList;
  }
}
