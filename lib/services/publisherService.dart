import 'dart:convert';

import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItem.dart';

class PublisherService {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String api = Environment().config.readrMeshApi;

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
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          source:{
            id:{
              equals: \$publisherId
            }
          }
          published_date:{
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
        }
      }
    }
    """;

    List<String> followingMemberIds = [];
    for (var memberId in UserHelper.instance.currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": UserHelper.instance.currentUser.memberId,
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
}
