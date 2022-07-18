import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';

import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItem.dart';

abstract class PublisherRepos {
  Future<List<NewsListItem>> fetchPublisherNews(
      String publisherId, DateTime newsFilterTime);
  Future<int> fetchPublisherFollowerCount(String publisherId);
}

class PublisherService implements PublisherRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String api = Get.find<EnvironmentService>().config.readrMeshApi;

  @override
  Future<List<NewsListItem>> fetchPublisherNews(
      String publisherId, DateTime newsFilterTime) async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$timeFilter: DateTime
      \$myId: ID
      \$publisherId: ID
    ){
    stories(
        take: 20
        orderBy:[
          {
            createdAt: desc
          },
          {
            published_date: desc
          },
        ]
        where:{
          is_active:{
            equals: true
          }
          source:{
            id:{
              equals: \$publisherId
            }
          }
          createdAt:{
            lt: \$timeFilter
          }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
        }
        full_content
        full_screen_ad
        paywall
        createdAt
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
            avatar_image{
              id
              resized{
                original
              }
            }
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
            avatar_image{
              id
              resized{
                original
              }
            }
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
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "publisherId": publisherId,
      "timeFilter": newsFilterTime.toUtc().toIso8601String()
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
      headers: {"Content-Type": "application/json"},
    );

    List<NewsListItem> allNews = [];
    if (jsonResponse['data']['stories'].isNotEmpty) {
      for (var item in jsonResponse['data']['stories']) {
        allNews.add(NewsListItem.fromJson(item));
      }
    }

    return allNews;
  }

  @override
  Future<int> fetchPublisherFollowerCount(String publisherId) async {
    const String query = '''
    query(
      \$publisherId: ID
    ){
      publisher(
        where:{
          id: \$publisherId
        }
      ){
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
      }
    }
    ''';

    Map<String, dynamic> variables = {"publisherId": publisherId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    if (jsonResponse.containsKey('errors')) {
      return 0;
    } else {
      return jsonResponse['data']['publisher']['followerCount'];
    }
  }
}
