import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pick.dart';

class PersonalFileService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

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
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

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

  Future<Map<String, dynamic>> fetchPickData(
      Member targetMember, Member currentMember,
      {DateTime? pickFilterTime}) async {
    const String query = """
    query(
      \$myId: ID
      \$followingMembers: [ID!]
      \$pickFilterTime: DateTime
      \$viewMemberId: ID
    ){
      member(
        where:{
          id: \$viewMemberId
        }
      ){
        storyPick: pick(
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
    }
    """;

    List<String> followingMemberIds = [];
    if (currentMember.following != null) {
      for (var memberId in currentMember.following!) {
        followingMemberIds.add(memberId.memberId);
      }
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": currentMember.memberId,
      "pickFilterTime":
          pickFilterTime ?? DateTime.now().toUtc().toIso8601String(),
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
    if (jsonResponse['data']['member']['storyPick'].isNotEmpty) {
      for (var pick in jsonResponse['data']['member']['storyPick']) {
        storyPickList.add(Pick.fromJson(pick));
      }
    }

    Map<String, dynamic> returnData = {
      'storyPickList': storyPickList,
    };

    return returnData;
  }

  Future<List<Pick>> fetchBookmark(Member currentMember,
      {DateTime? pickFilterTime}) async {
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
            }
          }
        }
      }
    }
    """;

    List<String> followingMemberIds = [];
    if (currentMember.following != null) {
      for (var memberId in currentMember.following!) {
        followingMemberIds.add(memberId.memberId);
      }
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": currentMember.memberId,
      "pickFilterTime":
          pickFilterTime ?? DateTime.now().toUtc().toIso8601String(),
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
}
