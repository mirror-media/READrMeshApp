import 'dart:convert';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/storyListItemList.dart';

abstract class TabStoryListRepos {
  void reduceSkip();
  Future<StoryListItemList> fetchStoryList({bool withCount = true});
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 18});
  Future<StoryListItemList> fetchProjectList({bool withCount = true});
  Future<StoryListItemList> fetchProjectListNextPage({int loadingMorePage = 2});
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug);
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug,
      {int loadingMorePage = 18});
  Future<StoryListItemList> fetchProjectListByCategorySlug(String slug);
  Future<StoryListItemList> fetchProjectListNextPageByCategorySlug(String slug,
      {int loadingMorePage = 2});
}

class TabStoryListServices implements TabStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  int storyListskip = 0,
      projectListSkip = 0,
      storyListFirst = 18,
      projectListFirst = 2;
  List<String> styleFilterList = ["project3", "embedded", "report"];
  final String query = """
  query (
    \$where: PostWhereInput,
    \$skip: Int,
    \$first: Int,
    \$withCount: Boolean!,
  ) {
    allPosts(
      where: \$where, 
      skip: \$skip, 
      first: \$first, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
      slug
      name
      publishTime
      style
      wordCount
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
    _allPostsMeta(
      where: \$where,
    ) @include(if: \$withCount) {
      count
    }
  }
  """;

  TabStoryListServices({this.storyListFirst = 18, this.projectListFirst = 2});

  @override
  void reduceSkip() {
    storyListskip = storyListskip - 12;
    projectListSkip = projectListSkip - 2;
  }

  @override
  Future<StoryListItemList> fetchStoryList({bool withCount = true}) async {
    String key = 'fetchStoryList?skip=$storyListskip&first=$storyListFirst';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": styleFilterList,
      },
      "skip": storyListskip,
      "first": storyListFirst,
      'withCount': withCount,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storyListskip > 30) {
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
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 12}) async {
    storyListskip = storyListskip + storyListFirst;
    storyListFirst = loadingMorePage;
    return await fetchStoryList();
  }

  @override
  Future<StoryListItemList> fetchProjectList({bool withCount = true}) async {
    String key =
        'fetchProjectList?skip=$projectListSkip&first=$projectListFirst';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_in": styleFilterList,
      },
      "skip": projectListSkip,
      "first": projectListFirst,
      'withCount': withCount,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (projectListSkip > 4) {
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
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchProjectListNextPage(
      {int loadingMorePage = 2}) async {
    projectListSkip = projectListSkip + projectListFirst;
    projectListFirst = loadingMorePage;
    return await fetchProjectList();
  }

  @override
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug,
      {bool withCount = true}) async {
    String key =
        'fetchStoryListByCategorySlug?slug=$slug&skip=$storyListskip&first=$storyListFirst';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": styleFilterList,
        "categories_some": {"slug": slug},
      },
      "skip": storyListskip,
      "first": storyListFirst,
      'withCount': withCount,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storyListskip > 30) {
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
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);

    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug,
      {int loadingMorePage = 12}) async {
    storyListskip = storyListskip + storyListFirst;
    storyListFirst = loadingMorePage;
    return await fetchStoryListByCategorySlug(slug);
  }

  @override
  Future<StoryListItemList> fetchProjectListByCategorySlug(String slug,
      {bool withCount = true}) async {
    String key =
        'fetchProjectListByCategorySlug?slug=$slug&skip=$projectListSkip&first=$projectListFirst';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_in": styleFilterList,
        "categories_some": {"slug": slug},
      },
      "skip": projectListSkip,
      "first": projectListFirst,
      'withCount': withCount,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (projectListSkip > 4) {
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
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);

    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchProjectListNextPageByCategorySlug(String slug,
      {int loadingMorePage = 2}) async {
    projectListSkip = projectListSkip + projectListFirst;
    projectListFirst = loadingMorePage;
    return await fetchStoryListByCategorySlug(slug);
  }
}
