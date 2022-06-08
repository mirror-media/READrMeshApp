import 'dart:convert';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/collection.dart';

import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/models/publisher.dart';

abstract class PersonalFileRepos {
  Future<Member> fetchMemberData(Member member);
  Future<List<Pick>> fetchStoryPicks(Member targetMember,
      {DateTime? pickFilterTime});
  Future<List<Pick>> fetchBookmark({DateTime? pickFilterTime});
  Future<List<Member>> fetchFollowerList(Member viewMember, {int skip = 0});
  Future<Map<String, dynamic>> fetchFollowingList(Member viewMember,
      {int skip = 0});
  Future<List<Publisher>> fetchFollowPublisher(Member viewMember);
  Future<List<Publisher>> fetchAllPublishers();
  Future<List<Collection>> fetchCollectionList(
    Member viewMember, {
    List<String>? fetchedCollectionIds,
  });
  Future<List<Collection>> fetchMoreCollectionList(
    Member viewMember,
    List<String> fetchedCollectionIds,
  );
}

class PersonalFileService implements PersonalFileRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String api = Get.find<EnvironmentService>().config.readrMeshApi;

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
        api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

  @override
  Future<Member> fetchMemberData(Member member) async {
    const String query = """
    query(
      \$memberId: ID
    ){
      member(
        where:{
          id: \$memberId
        }
      ){
        id
        nickname
        avatar
        email
        verified
        customId
        intro
        pickCount(
          where:{
            is_active:{
              equals: true
            }
            kind:{
              notIn:["bookmark"]
            }
          }
        )
        bookmarkCount: pickCount(
          where:{
            is_active:{
              equals: true
            }
            kind:{
              equals:"bookmark"
            }
          }
        )
        commentCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        followingCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        follow_publisherCount
      }
    }
    """;

    Map<String, dynamic> variables = {"memberId": member.memberId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    return Member.fromJson(jsonResponse['data']['member']);
  }

  @override
  Future<List<Pick>> fetchStoryPicks(Member targetMember,
      {DateTime? pickFilterTime}) async {
    const String query = """
query(
  \$myId: ID
  \$followingMembers: [ID!]
  \$pickFilterTime: DateTime
  \$viewMemberId: ID
){
  picks(
    where:{
      is_active:{
        equals: true
      }
      kind:{
        equals: "read"
      }
      objective:{
        equals: "story"
      }
      picked_date:{
        lt: \$pickFilterTime
      }
      story:{
        is_active:{
          equals: true
        }
      }
      member:{
        id:{
          equals: \$viewMemberId
        }
      }
    }
    orderBy:{
      picked_date: desc
    }
    take: 20
  ){
    id
    member{
      id
      nickname
      avatar
    }
    objective
    picked_date
    story{
      id
      title
      url
      published_date
      og_image
      full_content
      full_screen_ad
      paywall
      source{
        id
        title
      }
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
    pick_comment(
      where:{
        is_active:{
          equals: true
        }
      }
      take: 1
      orderBy:{
        published_date: desc
      }
    ){
      id
      member{
        id
        nickname
        avatar
        email
      }
      content
      state
      published_date
      likeCount
      is_edited
      isLiked:likeCount(
        where:{
          is_active:{
            equals: true
          }
          id:{
            equals: \$myId
          }
        }
      )
    }
  }
}
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "pickFilterTime": pickFilterTime?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
      "viewMemberId": targetMember.memberId
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Pick> storyPickList = [];
    if (jsonResponse['data']['picks'].isNotEmpty) {
      for (var pick in jsonResponse['data']['picks']) {
        storyPickList.add(Pick.fromJson(pick));
      }
    }

    return storyPickList;
  }

  @override
  Future<List<Pick>> fetchBookmark({DateTime? pickFilterTime}) async {
    const String query = """
    query(
      \$myId: ID
      \$followingMembers: [ID!]
      \$pickFilterTime: DateTime
    ){
      member(
        where:{
          id: \$myId
        }
      ){
        bookmark: pick(
          where:{
            is_active:{
              equals: true
            }
            kind:{
              equals: "bookmark"
            }
            picked_date:{
              lt: \$pickFilterTime
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 10
        ){
          id
          member{
            id
            nickname
            avatar
          }
          objective
          picked_date
          story{
            id
            title
            url
            published_date
            og_image
            full_content
            full_screen_ad
            paywall
            source{
              id
              title
              full_content
              full_screen_ad
            }
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

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "pickFilterTime": pickFilterTime?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Pick> bookmarkList = [];
    if (jsonResponse['data']['member']['bookmark'].isNotEmpty) {
      for (var pick in jsonResponse['data']['member']['bookmark']) {
        bookmarkList.add(Pick.fromJson(pick));
      }
    }

    return bookmarkList;
  }

  @override
  Future<List<Member>> fetchFollowerList(Member viewMember,
      {int skip = 0}) async {
    const String query = """
    query(
      \$viewMemberId: ID
      \$currentMemberId: ID
      \$skip: Int!
    ){
      members(
        where:{
          following:{
            some:{
              id:{
                equals: \$viewMemberId
              }
            }
          }
          is_active:{
            equals: true
          }
        }
        orderBy:{
          customId: asc
        }
        take: 10
        skip: \$skip
      ){
        id
        nickname
        customId
        avatar
        isFollowing: follower(
          where:{
            id:{
              equals: \$currentMemberId
            }
          }
        ){
          id
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "viewMemberId": viewMember.memberId,
      "currentMemberId": Get.find<UserService>().currentUser.memberId,
      "skip": skip,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Member> followerList = [];
    for (var member in jsonResponse['data']['members']) {
      Member follower = Member.fromJson(member);
      followerList.add(follower);
    }

    return followerList;
  }

  @override
  Future<Map<String, dynamic>> fetchFollowingList(Member viewMember,
      {int skip = 0}) async {
    const String query = """
    query(
      \$viewMemberId: ID
      \$currentMemberId: ID
      \$skip: Int!
    ){
      members(
        where:{
          follower:{
            some:{
              id:{
                equals: \$viewMemberId
              }
            }
          }
          is_active:{
            equals: true
          }
        }
        orderBy:{
          customId: asc
        }
        take: 10
        skip: \$skip
      ){
        id
        nickname
        customId
        avatar
        isFollowing: follower(
          where:{
            id:{
              equals: \$currentMemberId
            }
          }
        ){
          id
        }
      }
      membersCount(
        where:{
          follower:{
            some:{
              id:{
                equals: \$viewMemberId
              }
            }
          }
          is_active:{
            equals: true
          }
        }
      )
    }
    """;

    Map<String, dynamic> variables = {
      "viewMemberId": viewMember.memberId,
      "currentMemberId": Get.find<UserService>().currentUser.memberId,
      "skip": skip,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Member> followingList = [];
    for (var member in jsonResponse['data']['members']) {
      Member followingMember = Member.fromJson(member);
      followingList.add(followingMember);
    }

    return {
      'followingList': followingList,
      'followingMemberCount': jsonResponse['data']['membersCount'],
    };
  }

  @override
  Future<List<Publisher>> fetchFollowPublisher(Member viewMember) async {
    const String query = """
    query(
      \$viewMemberId: ID
    ){
      member(
        where:{
          id: \$viewMemberId
        }
      ){
        follow_publisher{
          id
          title
          logo
          customId
          followerCount(
            where:{
              is_active:{
                equals: true
              }
            }
          )
        }
      }
    }
    """;

    Map<String, dynamic> variables = {"viewMemberId": viewMember.memberId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Publisher> followPublisherList = [];
    for (var publisher in jsonResponse['data']['member']['follow_publisher']) {
      followPublisherList.add(Publisher.fromJson(publisher));
    }

    return followPublisherList;
  }

  @override
  Future<List<Publisher>> fetchAllPublishers() async {
    const String query = """
    query{
      publishers{
        id
        title
        customId
      }
    }
    """;

    Map<String, dynamic> variables = {};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<Publisher> allPublisherList = [];
    for (var publisher in jsonResponse['data']['publishers']) {
      allPublisherList.add(Publisher.fromJson(publisher));
    }

    return allPublisherList;
  }

  @override
  Future<List<Collection>> fetchCollectionList(
    Member viewMember, {
    List<String>? fetchedCollectionIds,
  }) async {
    const String query = """
    query(
      \$viewMemberId: ID
      \$fetchedCollectionIds: [ID!]
    ){
      collections(
        where:{
          id:{
            notIn: \$fetchedCollectionIds
          }
          status:{
            equals: "publish"
          }
          creator:{
            id:{
              equals: \$viewMemberId
            }
          }
        }
        take: 20
        orderBy:{
          createdAt: desc
        }
      ){
        id
        title
        slug
        public
        status
        heroImage{
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
          }
        )
      }
    }
    """;

    Map<String, dynamic> variables = {
      "viewMemberId": viewMember.memberId,
      "fetchedCollectionIds": fetchedCollectionIds ?? [],
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    return List<Collection>.from(jsonResponse['data']['collections'].map(
        (element) => Collection.fromFetchCollectionList(element, viewMember)));
  }

  @override
  Future<List<Collection>> fetchMoreCollectionList(
    Member viewMember,
    List<String> fetchedCollectionIds,
  ) async {
    return await fetchCollectionList(viewMember,
        fetchedCollectionIds: fetchedCollectionIds);
  }
}
