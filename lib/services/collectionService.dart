import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';

import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class CollectionRepos {
  Future<List<CollectionStory>> fetchPickAndBookmark({
    List<String>? fetchedIds,
  });
  Future<Collection> createCollection({
    required String title,
    required String ogImageUrl,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
  });
  Future<Collection> createCollectionPicks({
    required Collection collection,
    required List<CollectionStory> collectionStory,
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
        .map((story) => CollectionStory.fromStory(story)));
  }

  @override
  Future<Collection> createCollection({
    required String title,
    required String ogImageUrl,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
  }) async {
    const String mutation = """
    mutation(
      \$title: String
      \$slug: String
      \$creatorId: ID
      \$public: String
      \$format: String
    ){
      createCollection(
        data:{
          title: \$title,
          slug: \$slug,
          public: \$public,
          format: \$format,
          creator:{
            connect:{
              id: \$creatorId
            }
          }
        }
      ){
        id
        slug
        createdAt
      }
    }
    """;

    Map<String, String> variables = {
      "title": title,
      "slug": slug ?? '${DateTime.now()}_$hashCode',
      "public": public.toString().split('.').last,
      "format": format.toString().split('.').last,
      "creatorId": Get.find<UserService>().currentUser.memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(needAuth: true),
    );

    return Collection(
      id: jsonResponse['data']['createCollection']['id'],
      title: title,
      slug: jsonResponse['data']['createCollection']['slug'],
      creator: Get.find<UserService>().currentUser,
      format: format,
      public: public,
      controllerTag:
          'Collection${jsonResponse['data']['createCollection']['id']}',
      ogImageUrl: ogImageUrl,
      publishedTime: DateTime.tryParse(
              jsonResponse['data']['createCollection']['createdAt']) ??
          DateTime.now(),
    );
  }

  @override
  Future<Collection> createCollectionPicks({
    required Collection collection,
    required List<CollectionStory> collectionStory,
  }) async {
    const String mutation = """
    mutation(
      \$myId: ID
      \$followingMembers: [ID!]
      \$data: [CollectionPickCreateInput!]!
    ){
      createCollectionPicks(
        data:\$data
      ){
        id
        sort_order
        picked_date
        creator{
          id
          nickname
          avatar
          customId
        }
        story{
          id
            title
            url
            source{
              id
              title
            }
            full_content
            full_screen_ad
            paywall
            published_date
            og_image
            followingPicks: pick(
              where:{
                member:{
                  id:{
                    in: \$followingMembers
                  }
                }
                state:{
                  equals: "public"
                }
                kind:{
                  equals: "read"
                }
                is_active:{
                  equals: true
                }
              }
              orderBy:{
                picked_date: desc
              }
              take: 4
            ){
              member{
                id
                nickname
                avatar
                customId
              }
            }
            otherPicks:pick(
              where:{
                member:{
                  id:{
                    notIn: \$followingMembers
                    not:{
                      equals: \$myId
                    }
                  }
                }
                state:{
                  in: "public"
                }
                kind:{
                  equals: "read"
                }
                is_active:{
                  equals: true
                }
              }
              orderBy:{
                picked_date: desc
              }
              take: 4
            ){
              member{
                id
                nickname
                avatar
                customId
              }
            }
            pickCount(
              where:{
                state:{
                  in: "public"
                }
                is_active:{
                  equals: true
                }
              }
            )
            commentCount(
              where:{
                state:{
                  in: "public"
                }
                is_active:{
                  equals: true
                }
              }
            )
            myPickId: pick(
              where:{
                member:{
                  id:{
                    equals: \$myId
                  }
                }
                state:{
                  notIn: "private"
                }
                kind:{
                  equals: "read"
                }
                is_active:{
                  equals: true
                }
              }
            ){
              id
              pick_comment(
                where:{
                  is_active:{
                    equals: true
                  }
                }
              ){
                id
              }
            }
        }
      }
    }
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<Map<String, dynamic>> dataList = [];
    for (var item in collectionStory) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.news!.id}
        },
        "collection": {
          "connect": {"id": collection.id}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String()
      };
      dataList.add(createInput);
    }

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "followingMembers": followingMemberIds,
      "data": dataList,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(needAuth: true),
    );

    List<CollectionStory> collectionPicks = [];
    for (var result in jsonResponse['data']['createCollectionPicks']) {
      collectionPicks.add(CollectionStory.fromJson(result));
    }

    collection.collectionPicks = collectionPicks;
    return collection;
  }
}
