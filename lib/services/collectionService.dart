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
  Future<Map<String, List<CollectionStory>>> fetchPickAndBookmark({
    List<String>? fetchedStoryIds,
  });
  Future<Collection> createCollection({
    required String title,
    required String ogImageUrl,
    required List<CollectionStory> collectionStory,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
  });
  Future<Collection> createCollectionPicks({
    required Collection collection,
    required List<CollectionStory> collectionStory,
  });
  Future<Collection> updateTitleAndOg({
    required String collectionId,
    required String heroImageId,
    required String newTitle,
    required String newOgUrl,
  });
  Future<void> updateCollectionPicksOrder({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  });
  Future<void> removeCollectionPicks(
      {required List<CollectionStory> collectionStory});
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
  Future<Map<String, List<CollectionStory>>> fetchPickAndBookmark({
    List<String>? fetchedStoryIds,
  }) async {
    const String query = """
    query(
      \$myId: ID
      \$fetchedStoryIds: [ID!]
    ){
      bookmarks: picks(
        where:{
          member:{
            id:{
              equals: \$myId
            }
          }
          story:{
            is_active:{
              equals: true
            }
            id:{
              notIn: \$fetchedStoryIds
            }
          }
          is_active:{
            equals: true
          }
          objective:{
            equals: "story"
          }
          kind:{
            equals: "bookmark"
          }
        }
        take: 100
        orderBy:{
          picked_date: desc
        }
      ){
        picked_date
        story{
          id
          title
          url
          published_date
          og_image
          source{
            id
            title
          }
        }
      }
      picks: picks(
        where:{
          member:{
            id:{
              equals: \$myId
            }
          }
          story:{
            is_active:{
              equals: true
            }
            id:{
              notIn: \$fetchedStoryIds
            }
          }
          is_active:{
            equals: true
          }
          objective:{
            equals: "story"
          }
          kind:{
            equals: "read"
          }
        }
        take: 100
        orderBy:{
          picked_date: desc
        }
      ){
        picked_date
        story{
          id
          title
          url
          published_date
          og_image
          source{
            id
            title
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "fetchedStoryIds": fetchedStoryIds ?? [],
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

    List<CollectionStory> pickAndBookmarkList = [];
    List<CollectionStory> pickList = [];
    List<CollectionStory> bookmarkList = [];
    Map<String, DateTime> pickTime = {};
    for (var bookmark in jsonResponse['data']['bookmarks']) {
      CollectionStory collectionStory = CollectionStory.fromPick(bookmark);
      pickAndBookmarkList.add(collectionStory);
      bookmarkList.add(collectionStory);
      pickTime.putIfAbsent(collectionStory.news!.id,
          () => DateTime.parse(bookmark['picked_date']));
    }
    for (var pick in jsonResponse['data']['picks']) {
      CollectionStory collectionStory = CollectionStory.fromPick(pick);
      pickList.add(collectionStory);
      int index = pickAndBookmarkList.indexWhere(
          (element) => element.news!.id == collectionStory.news!.id);
      if (index != -1) {
        pickAndBookmarkList[index]
            .pickKinds!
            .add(collectionStory.pickKinds!.first);
      } else {
        pickAndBookmarkList.add(collectionStory);
      }
      pickTime.update(
        collectionStory.news!.id,
        (value) {
          if (value.isAfter(pick['picked_date'])) {
            return value;
          }
          return DateTime.parse(pick['picked_date']);
        },
        ifAbsent: () => DateTime.parse(pick['picked_date']),
      );
    }

    pickAndBookmarkList
        .sort((a, b) => pickTime[b.news!.id]!.compareTo(pickTime[a.news!.id]!));

    return {
      'pickAndBookmarkList': pickAndBookmarkList,
      'pickList': pickList,
      'bookmarkList': bookmarkList,
    };
  }

  @override
  Future<Collection> createCollection({
    required String title,
    required String ogImageUrl,
    required List<CollectionStory> collectionStory,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
  }) async {
    const String mutation = """
    mutation(
  \$title: String
  \$slug: String
  \$myId: ID
  \$public: String
  \$format: String
  \$heroImageUrl: String
  \$collectionpicks: [CollectionPickCreateInput!]
  \$followingMembers: [ID!]
){
  createCollection(
    data:{
      title: \$title,
      slug: \$slug,
      public: \$public,
      format: \$format,
      status: "publish"
      creator:{
      	connect:{
          id: \$myId
        }
      }
      heroImage:{
        create:{
          name: \$slug
          urlOriginal: \$heroImageUrl
        }
      }
      collectionpicks:{
        create: \$collectionpicks
      }
    }
  ){
    id
    slug
    createdAt
    heroImage{
      id
    }
    collectionpicks{
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
}
    """;

    List<Map<String, dynamic>> collectionStoryList = [];
    for (var item in collectionStory) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.news!.id}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String()
      };
      collectionStoryList.add(createInput);
    }

    Map<String, dynamic> variables = {
      "title": title,
      "slug": slug ?? '${DateTime.now()}_$hashCode',
      "public": public.toString().split('.').last,
      "format": format.toString().split('.').last,
      "myId": Get.find<UserService>().currentUser.memberId,
      "heroImageUrl": ogImageUrl,
      "collectionpicks": collectionStoryList,
      "followingMembers": Get.find<UserService>().followingMemberIds,
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
    for (var result in jsonResponse['data']['createCollection']
        ['collectionpicks']) {
      collectionPicks.add(CollectionStory.fromJson(result));
    }

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
      collectionPicks: collectionPicks,
      ogImageId: jsonResponse['data']['createCollection']['heroImage']['id'],
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

  @override
  Future<Collection> updateTitleAndOg({
    required String collectionId,
    required String heroImageId,
    required String newTitle,
    required String newOgUrl,
  }) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$heroImageId: ID
  \$newTitle: String
  \$newOgUrl: String
  \$followingMembers: [ID!]
  \$myId: ID
){
  updatePhoto(
    where:{
      id: \$heroImageId
    }
    data:{
      urlOriginal: \$newOgUrl
    }
  ){
    urlOriginal
  }
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      title: \$newTitle
    }
  ){
    id
    title
    slug
    public
    status
    heroImage{
      id
      urlOriginal
      file{
        url
      }
    }
    format
    createdAt
    commentCount(
      where:{
        is_active:{
          equals: true
        }
        state:{
          equals: "public"
        }
        member:{
          is_active:{
            equals: true
          }
        }
      }
    )
    followingPicks: picks(
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
    otherPicks:picks(
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
    picksCount(
      where:{
        state:{
          in: "public"
        }
        is_active:{
          equals: true
        }
      }
    )
    myPickId: picks(
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
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "heroImageId": heroImageId,
      "newTitle": newTitle,
      "newOgUrl": newOgUrl,
      "myId": Get.find<UserService>().currentUser.memberId,
      "followingMembers": Get.find<UserService>().followingMemberIds,
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

    return Collection.fromFetchCollectionList(
        jsonResponse['data']['updateCollection'],
        Get.find<UserService>().currentUser);
  }

  @override
  Future<void> updateCollectionPicksOrder({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  }) async {
    const String mutation = """
mutation(
  \$data: [CollectionPickUpdateArgs!]!
){
  updateCollectionPicks(
    data: \$data
  ){
    id
  }
}
    """;

    List<Map> dataList = [];

    for (var item in collectionStory) {
      dataList.add({
        "where": {"id": item.id},
        "data": {
          "sort_order": item.sortOrder,
          "updated_date": DateTime.now().toUtc().toIso8601String(),
        }
      });
    }

    Map<String, dynamic> variables = {
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

    if (jsonResponse.containsKey('errors')) {
      throw Exception('Update collection pick order error');
    }
  }

  @override
  Future<void> removeCollectionPicks(
      {required List<CollectionStory> collectionStory}) async {
    const String mutation = """
mutation(
  \$data: [CollectionPickUpdateArgs!]!
){
  updateCollectionPicks(
    data: \$data
  ){
    id
  }
}
    """;

    List<Map> dataList = [];

    for (var item in collectionStory) {
      dataList.add({
        "where": {"id": item.id},
        "data": {
          "collection": {"disconnect": true}
        }
      });
    }

    Map<String, dynamic> variables = {
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

    if (jsonResponse.containsKey('errors')) {
      throw Exception('Update collection pick order error');
    }
  }
}
