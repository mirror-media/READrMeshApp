import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';

abstract class LatestRepos {
  Future<List<NewsListItem>> fetchLatestNews({DateTime? lastNewsPublishTime});

  Future<List<NewsListItem>> fetchMoreLatestNews();

  Future<List<Publisher>> fetchRecommendPublishers();
}

class LatestService implements LatestRepos {
  DateTime _earliestNewsPublishTime = DateTime.now();
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<List<NewsListItem>> fetchLatestNews(
      {DateTime? lastNewsPublishTime}) async {
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
      \$timeFilter: DateTime
      \$followingMembers: [ID!]
      \$myId: ID
      \$lastNewsPublishTime: DateTime
      \$blockAndBlockedIds: [ID!]
    ){
      stories(
        take: 60
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
              in: \$followingPublisherIds
            }
          }
          createdAt:{
            lt: \$lastNewsPublishTime
            gte: \$timeFilter
          }
        }
      ){
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
        createdAt
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

    int duration =
        Get.find<SharedPreferencesService>().prefs.getInt('newsCoverage') ?? 24;
    //GQL DateTime must be Iso8601 format
    String timeFilter = DateTime.now()
        .subtract(Duration(hours: duration))
        .toUtc()
        .toIso8601String();

    List<String> followingMemberIds = [];
    List<String> followingPublisherIds = [];

    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "timeFilter": timeFilter,
      "lastNewsPublishTime": lastNewsPublishTime?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<NewsListItem> allLatestNews = [];
    if (jsonResponse['stories'].isNotEmpty) {
      for (var item in jsonResponse['stories']) {
        allLatestNews.add(NewsListItem.fromJson(item));
      }
      _earliestNewsPublishTime = allLatestNews.last.publishedDate;
      int start = allLatestNews.indexWhere((element) =>
          element.publishedDate.difference(DateTime.now()).inMinutes > 60);

      if (start != -1) {
        List<NewsListItem> tempList = allLatestNews.sublist(0, start);
        List<NewsListItem> needSortNews = allLatestNews.sublist(start);

        needSortNews.sort(
            (a, b) => b.publishedDate.hour.compareTo(a.publishedDate.hour));
        allLatestNews.assignAll(tempList);
        allLatestNews.addAll(needSortNews);
      }
    }

    return allLatestNews;
  }

  @override
  Future<List<NewsListItem>> fetchMoreLatestNews() async {
    return await fetchLatestNews(lastNewsPublishTime: _earliestNewsPublishTime);
  }

  @override
  Future<List<Publisher>> fetchRecommendPublishers() async {
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
      \$readrId: ID
      \$followingMembers: [ID!]
    ){
      publishers(
        where:{
          id:{
            notIn: \$followingPublisherIds
            not:{
              equals: \$readrId
            }
          }
        }
      ){
        id
        title
        logo
        follower(
          where:{
            id:{
              in: \$followingMembers
            }
            is_active:{
              equals: true
            }
          }
          take: 1
        ){
          id
          nickname
          customId
        }
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
      }
    }
    """;

    List<String> followingMemberIds = [];
    List<String> followingPublisherIds = [];

    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "readrId": Get.find<EnvironmentService>().config.readrPublisherId,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<Publisher> recommendedPublishers = [];
    if (jsonResponse['publishers'].isNotEmpty) {
      for (var publisher in jsonResponse['publishers']) {
        recommendedPublishers.add(Publisher.fromJson(publisher));
      }
    }

    return recommendedPublishers;
  }
}
