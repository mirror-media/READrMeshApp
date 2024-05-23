import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsListItem.dart';

abstract class TabStoryListRepos {
  Future<Map<String, List<NewsListItem>>> fetchStoryList({
    int storySkip = 0,
    int storyTake = 18,
    int projectSkip = 0,
    int projectTake = 2,
  });

  Future<Map<String, List<NewsListItem>>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyTake = 18,
    int projectSkip = 0,
    int projectTake = 2,
  });

  Future<List<NewsListItem>> fetchMeshStoryList(List<String> storyIdList);
}

class TabStoryListServices implements TabStoryListRepos {
  final List<String> _fetchedStoryIdList = [];
  final List<String> _fetchedProjectIdList = [];
  final ProxyServerService proxyServerService = Get.find();

  final String query = """
  query (
    \$storyWhere: PostWhereInput,
    \$projectWhere: PostWhereInput,
    \$storySkip: Int,
    \$storyTake: Int,
    \$projectSkip: Int,
    \$projectTake: Int,
  ) {
    story: posts(
      where: \$storyWhere, 
      skip: \$storySkip, 
      take: \$storyTake, 
      orderBy: [ { publishTime: desc } ]
    ) {
      id
    }
    project: posts(
      where: \$projectWhere, 
      skip: \$projectSkip, 
      take: \$projectTake, 
      orderBy: [ { publishTime: desc } ]
    ) {
      id
    }
  }
  """;

  @override
  Future<Map<String, List<NewsListItem>>> fetchStoryList({
    int storySkip = 0,
    int storyTake = 18,
    int projectSkip = 0,
    int projectTake = 2,
  }) async {
    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": {"equals": "published"},
        "style": {
          "in": ["news", "scrollablevideo"]
        },
        "id": {"notIn": _fetchedStoryIdList},
      },
      "projectWhere": {
        "state": {"equals": "published"},
        "style": {
          "in": ["project3", "embedded", "report"]
        },
        "id": {"notIn": _fetchedProjectIdList},
      },
      "storySkip": storySkip,
      "storyTake": storyTake,
      "projectSkip": projectSkip,
      "projectTake": projectTake
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.readr,
      queryBody: query,
      variables: variables,
      cacheDuration: 30.minutes,
    );

    List<String> storyList = [];
    List<String> projectList = [];
    for (var item in jsonResponse.data!['story']) {
      _fetchedStoryIdList.add(item['id']);
      storyList.add(item['id']);
    }

    for (var item in jsonResponse.data!['project']) {
      _fetchedProjectIdList.add(item['id']);
      projectList.add(item['id']);
    }

    var futureList = await Future.wait([
      fetchMeshStoryList(storyList),
      fetchMeshStoryList(projectList),
    ]);

    Map<String, List<NewsListItem>> mixedStoryList = {
      'story': futureList[0],
      'project': futureList[1],
    };

    return mixedStoryList;
  }

  @override
  Future<Map<String, List<NewsListItem>>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyTake = 18,
    int projectSkip = 0,
    int projectTake = 2,
  }) async {
    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": {"equals": "published"},
        "style": {
          "in": ["news"]
        },
        "categories": {
          "some": {
            "slug": {"equals": slug}
          }
        },
        "id": {"notIn": _fetchedStoryIdList},
      },
      "projectWhere": {
        "state": {"equals": "published"},
        "style": {
          "in": ["project3", "embedded", "report"]
        },
        "categories": {
          "some": {
            "slug": {"equals": slug}
          }
        },
        "id": {"notIn": _fetchedProjectIdList},
      },
      "storySkip": storySkip,
      "storyTake": storyTake,
      "projectSkip": projectSkip,
      "projectTake": projectTake,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.readr,
      queryBody: query,
      variables: variables,
      cacheDuration: 30.minutes,
    );

    List<String> storyList = [];
    List<String> projectList = [];
    for (var item in jsonResponse.data!['story']) {
      _fetchedStoryIdList.add(item['id']);
      storyList.add(item['id']);
    }

    for (var item in jsonResponse.data!['project']) {
      _fetchedProjectIdList.add(item['id']);
      projectList.add(item['id']);
    }

    var futureList = await Future.wait([
      fetchMeshStoryList(storyList),
      fetchMeshStoryList(projectList),
    ]);

    Map<String, List<NewsListItem>> mixedStoryList = {
      'story': futureList[0],
      'project': futureList[1],
    };

    return mixedStoryList;
  }

  @override
  Future<List<NewsListItem>> fetchMeshStoryList(
      List<String> storyIdList) async {
    const String query = '''
    query(
      \$storyIdList: [String!]
      \$followingMembers: [ID!]
      \$myId: ID
      \$readrId: ID
      \$blockAndBlockedIds: [ID!]
    ){
      stories(
        where:{
          source:{
            id:{
              equals: \$readrId
            }
          }
          content:{
            in: \$storyIdList
          }
       
          is_active:{
            equals: true
          }
        }
        orderBy:[
          {
            createdAt: desc
          },
          {
            published_date: desc
          },
        ]
      ){
        id
        title
        url
        content
        source{
          id
          title
          full_content
          full_screen_ad
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
    ''';

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "storyIdList": storyIdList,
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "urlFilter": Get.find<EnvironmentService>().config.readrWebsiteLink,
      "readrId": Get.find<EnvironmentService>().config.readrPublisherId,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<NewsListItem> newsList = [];
    for (var item in jsonResponse.data!['stories']) {
      newsList.add(NewsListItem.fromJson(item));
    }

    return newsList;
  }
}
