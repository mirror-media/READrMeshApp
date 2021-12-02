import 'dart:convert';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/storyListItemList.dart';

abstract class AuthorStoryListRepos {
  Future<StoryListItemList> fetchStoryListByAuthorSlug(
    String slug, {
    int skip = 0,
    int first = 10,
    bool withCount = true,
  });
}

class AuthorStoryListServices implements AuthorStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

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
    _allPostsMeta(
      where: \$where,
    ) @include(if: \$withCount) {
      count
    }
  }
  """;

  @override
  Future<StoryListItemList> fetchStoryListByAuthorSlug(
    String slug, {
    int skip = 0,
    int first = 10,
    bool withCount = true,
  }) async {
    String key =
        'fetchStoryListByAuthorSlug?authorSlug=$slug&skip=$skip&first=$first';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "OR": [
          {
            "writers_some": {"slug": slug}
          },
          {
            "photographers_some": {"slug": slug}
          },
          {
            "cameraOperators_some": {"slug": slug}
          },
          {
            "designers_some": {"slug": slug}
          },
          {
            "engineers_some": {"slug": slug}
          },
          {
            "dataAnalysts_some": {"slug": slug}
          }
        ]
      },
      "skip": skip,
      "first": first,
      "withCount": withCount
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (skip > 20) {
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
}
