import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/models/category.dart';

abstract class CategoryRepos {
  Future<List<Category>> fetchCategoryList();
}

class CategoryServices implements CategoryRepos {
  @override
  Future<List<Category>> fetchCategoryList() async {
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

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.readr,
      queryBody: query,
      variables: variables,
      cacheDuration: 24.hours,
    );

    List<Category> categoryList = List<Category>.from(jsonResponse
        .data!['allCategories']
        .map((item) => Category.fromJson(item)));

    categoryList.sort((a, b) => b.latestPostTime!.compareTo(a.latestPostTime!));
    categoryList.insert(
        0,
        Category(
          id: '0',
          name: 'slugLatest'.tr,
          slug: 'latest',
        ));

    return categoryList;
  }
}
