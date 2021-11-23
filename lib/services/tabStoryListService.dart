import 'dart:convert';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/storyListItemList.dart';

abstract class TabStoryListRepos {
  Future<List<StoryListItemList>> fetchStoryList({
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
    bool withCount = true,
  });
  Future<List<StoryListItemList>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
    bool withCount = true,
  });
}

class TabStoryListServices implements TabStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String query = """
  query (
    \$storyWhere: PostWhereInput,
    \$projectWhere: PostWhereInput,
    \$storySkip: Int,
    \$storyFirst: Int,
    \$projectSkip: Int,
    \$projectFirst: Int,
    \$withCount: Boolean!,
  ) {
    story: allPosts(
      where: \$storyWhere, 
      skip: \$storySkip, 
      first: \$storyFirst, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
      slug
      name
      publishTime
      style
      readingTime
      categories(where: {
        state: active
      }){
        id
        name
        slug
      }
      heroImage {
        urlMobileSized
      }
    }
    project:allPosts(
      where: \$projectWhere, 
      skip: \$projectSkip, 
      first: \$projectFirst, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
      slug
      name
      publishTime
      style
      readingTime
      categories(where: {
        state: active
      }){
        id
        name
        slug
      }
      heroImage {
        urlMobileSized
      }
    }
    storyCount:_allPostsMeta(
      where: \$storyWhere,
    ) @include(if: \$withCount) {
      count
    }
    projectCount:_allPostsMeta(
      where: \$projectWhere,
    ) @include(if: \$withCount) {
      count
    }
  }
  """;

  @override
  Future<List<StoryListItemList>> fetchStoryList({
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
    bool withCount = true,
  }) async {
    String key =
        'fetchStoryList?storySkip=$storySkip&storyFirst=$storyFirst&projectSkip=$projectSkip&projectFirst=$projectFirst';

    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": "published",
        "style_in": ["news"]
      },
      "projectWhere": {
        "state": "published",
        "style_in": ["project3", "embedded", "report"]
      },
      "storySkip": storySkip,
      "storyFirst": storyFirst,
      "projectSkip": projectSkip,
      "projectFirst": projectFirst,
      "withCount": withCount
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storySkip > 30) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['story']);
    StoryListItemList projectList =
        StoryListItemList.fromJson(jsonResponse['data']['project']);
    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['storyCount']['count'];
      projectList.allStoryCount = jsonResponse['data']['projectCount']['count'];
    }

    List<StoryListItemList> mixedStoryList = [newsList, projectList];

    return mixedStoryList;
  }

  @override
  Future<List<StoryListItemList>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
    bool withCount = true,
  }) async {
    String key =
        'fetchStoryListByCategorySlug?slug=$slug&storySkip=$storySkip&storyFirst=$storyFirst&projectSkip=$projectSkip&projectFirst=$projectFirst';

    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": "published",
        "style_in": ["news"],
        "categories_some": {"slug": slug}
      },
      "projectWhere": {
        "state": "published",
        "style_in": ["project3", "embedded", "report"],
        "categories_some": {"slug": slug}
      },
      "storySkip": storySkip,
      "storyFirst": storyFirst,
      "projectSkip": projectSkip,
      "projectFirst": projectFirst,
      "withCount": withCount
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storySkip > 30) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['story']);
    StoryListItemList projectList =
        StoryListItemList.fromJson(jsonResponse['data']['project']);
    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['storyCount']['count'];
      projectList.allStoryCount = jsonResponse['data']['projectCount']['count'];
    }

    List<StoryListItemList> mixedStoryList = [newsList, projectList];

    return mixedStoryList;
  }
}
