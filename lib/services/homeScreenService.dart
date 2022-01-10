import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItemList.dart';

class HomeScreenService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  static Map<String, String> getHeaders(String token) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    headers.addAll({"Authorization": "Bearer $token"});

    return headers;
  }

  // Get News selet CMS User token for authorization
  // TODO: Delete when verify firebase token is finished
  Future<String> _fetchCMSUserToken() async {
    String mutation = """
    mutation(
	    \$email: String!,
	    \$password: String!
    ){
	    authenticateUserWithPassword(
		    email: \$email
		    password: \$password
	    ){
		    token
	    }
    }
    """;

    Map<String, String> variables = {
      "email": DevConfig().appHelperEmail,
      "password": DevConfig().appHelperPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['token'];

    return token;
  }

  Future<NewsListItemList> fetchNewsList() async {
    const String query = """
    query(
        \$storyWhere: StoryWhereInput!
      ){
        stories(
          where: \$storyWhere
          orderBy: [{published_date: desc}]
        ){
          id
          title
          url
          summary
          content
          source{
            id
            title
          }
          category{
            id
            title
            slug
          }
          published_date
          og_image
        }
        storiesCount
      }
    """;

    Map<String, dynamic> variables = {
      "storyWhere": {
        "published_date": {
          "gte": DateTime.now()
              .subtract(const Duration(hours: 24))
              .toUtc()
              .toIso8601String()
        }
      }
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    String key = 'fetchNewsList';
    jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      api,
      jsonEncode(graphqlBody.toJson()),
      maxAge: newsTabStoryList,
      headers: {"Content-Type": "application/json"},
    );

    NewsListItemList newsList = NewsListItemList();
    if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
      newsList = NewsListItemList.fromJson(jsonResponse['data']['stories']);
      newsList.allStoryCount = jsonResponse['data']['storiesCount'];
    }

    return newsList;
  }
}
