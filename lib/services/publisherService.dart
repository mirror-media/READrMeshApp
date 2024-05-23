import 'package:get/get.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsListItem.dart';

abstract class PublisherRepos {
  Future<List<NewsListItem>> fetchPublisherNews(
      String publisherId, DateTime newsFilterTime);

  Future<int> fetchPublisherFollowerCount(String publisherId);
}

class PublisherService implements PublisherRepos {
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<List<NewsListItem>> fetchPublisherNews(
      String publisherId, DateTime newsFilterTime) async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$timeFilter: DateTime
      \$myId: ID
      \$publisherId: ID
      \$blockAndBlockedIds: [ID!]
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
              AND:[
                {
                  id:{
                    notIn: \$followingMembers
                    not:{
                      equals: \$myId
                    }
                  }
                }
                {
                  id:{
                    notIn: \$blockAndBlockedIds
                  }
                }
                {
                  is_active:{
                    equals: true
                  }
                }
              ]
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
            member:{
              id:{
                notIn: \$blockAndBlockedIds
              }
              is_active:{
                equals: true
              }
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
            member:{
              id:{
                notIn: \$blockAndBlockedIds
              }
              is_active:{
                equals: true
              }
            }
          }
        )
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
      "timeFilter": newsFilterTime.toUtc().toIso8601String(),
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<NewsListItem> allNews = [];
    if (jsonResponse['stories'].isNotEmpty) {
      for (var item in jsonResponse['stories']) {
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

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    if (jsonResponse.hasException) {
      return 0;
    } else {
      return jsonResponse['publisher']['followerCount'] ?? 0;
    }
  }
}
