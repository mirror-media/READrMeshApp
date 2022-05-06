import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';

import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class CollectionRepos {
  Future<List<CollectionStory>> fetchPickAndBookmark({
    List<String>? fetchedIds,
  });
}

class CollectionService implements CollectionRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String _api = Get.find<EnvironmentService>().config.readrMeshApi;

  Future<Map<String, String>> _getHeaders({bool needAuth = false}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (needAuth) {
      // TODO: Change back to firebase token when verify firebase token is finished
      String token = await _fetchCMSUserToken();
      //String token = await FirebaseAuth.instance.currentUser!.getIdToken();
      headers.addAll({"Authorization": "Bearer $token"});
    }

    return headers;
  }

  // Get READr CMS User token for authorization
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
        ... on UserAuthenticationWithPasswordSuccess{
        	sessionToken
      	}
        ... on UserAuthenticationWithPasswordFailure{
          message
      	}
      }
    }
    """;

    Map<String, String> variables = {
      "email": Get.find<EnvironmentService>().config.appHelperEmail,
      "password": Get.find<EnvironmentService>().config.appHelperPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        _api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

  @override
  Future<List<CollectionStory>> fetchPickAndBookmark({
    List<String>? fetchedIds,
  }) async {
    const String query = """
    query(
      \$myId: ID
      \$fetchedIds: [ID!]
    ){
      stories(
        where:{
          is_active:{
            equals: true
          }
          id:{
            notIn: \$fetchedIds
          }
          pick:{
            some:{
              member:{
                id:{
                  equals:\$myId
                }
              }
              objective:{
                equals: "story"
              }
              kind:{
                in:["read","bookmark"]
              }
              is_active:{
                equals: true
              }
            }
          }
        }
        take: 50
        orderBy:{
          published_date: desc
        }
      ){
        id
        title
        url
        published_date
        og_image
        source{
          id
          title
        }
        pick(
          where:{
            member:{
              id:{
                equals: \$myId
              }
            }
            is_active:{
              equals: true
            }
            kind:{
              in:["read","bookmark"]
            }
          }
        ){
          kind
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "fetchedIds": fetchedIds ?? [],
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    return List<CollectionStory>.from(jsonResponse['data']['stories']
        .map((story) => CollectionStory.fromJson(story)));
  }
}
