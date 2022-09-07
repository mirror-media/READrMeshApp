import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/newsListItem.dart';

abstract class TabStoryListRepos {
  Future<Map<String, List<NewsListItem>>> fetchStoryList({
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
  });
  Future<Map<String, List<NewsListItem>>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
  });
  Future<List<NewsListItem>> fetchMeshStoryList(List<String> storyIdList);
}

class TabStoryListServices implements TabStoryListRepos {
  final List<String> _fetchedStoryIdList = [];
  final List<String> _fetchedProjectIdList = [];

  final String query = """
  query (
    \$storyWhere: PostWhereInput,
    \$projectWhere: PostWhereInput,
    \$storySkip: Int,
    \$storyFirst: Int,
    \$projectSkip: Int,
    \$projectFirst: Int,
  ) {
    story: allPosts(
      where: \$storyWhere, 
      skip: \$storySkip, 
      first: \$storyFirst, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
    }
    project:allPosts(
      where: \$projectWhere, 
      skip: \$projectSkip, 
      first: \$projectFirst, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
    }
  }
  """;

  @override
  Future<Map<String, List<NewsListItem>>> fetchStoryList({
    int storySkip = 0,
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
  }) async {
    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": "published",
        "style_in": ["news", "scrollablevideo"],
        "id_not_in": _fetchedStoryIdList,
      },
      "projectWhere": {
        "state": "published",
        "style_in": ["project3", "embedded", "report"],
        "id_not_in": _fetchedProjectIdList,
      },
      "storySkip": storySkip,
      "storyFirst": storyFirst,
      "projectSkip": projectSkip,
      "projectFirst": projectFirst
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
    int storyFirst = 18,
    int projectSkip = 0,
    int projectFirst = 2,
  }) async {
    Map<String, dynamic> variables = {
      "storyWhere": {
        "state": "published",
        "style_in": ["news"],
        "categories_some": {"slug": slug},
        "id_not_in": _fetchedStoryIdList,
      },
      "projectWhere": {
        "state": "published",
        "style_in": ["project3", "embedded", "report"],
        "categories_some": {"slug": slug},
        "id_not_in": _fetchedProjectIdList,
      },
      "storySkip": storySkip,
      "storyFirst": storyFirst,
      "projectSkip": projectSkip,
      "projectFirst": projectFirst,
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
      \$urlFilter: String!
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
          url:{
            contains: \$urlFilter
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

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    List<NewsListItem> newsList = [];
    for (var item in jsonResponse.data!['stories']) {
      newsList.add(NewsListItem.fromJson(item));
    }

    return newsList;
  }
}
