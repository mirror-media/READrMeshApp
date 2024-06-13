import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsListItem.dart';

abstract class TabStoryListRepos {
  Future<List<NewsListItem>> fetchStoryList({
    int storySkip = 0,
    int storyTake = 18,
  });

  Future<List<NewsListItem>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyTake = 18,
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
  Future<List<NewsListItem>> fetchStoryList({
    int storySkip = 0,
    int storyTake = 18,
  }) async {
    const query = '''
          query(
            \$skip: Int,
            \$take: Int,
          ){
            stories(
              take:\$take,
              skip:\$skip,
              orderBy:{
                published_date:desc
              }
              where:{
                source:{
                  title:{
                    equals:"READr"
                  }
                }
              }
            ){
              id
              title
        }
      }
    ''';

    final jsonResponse = await proxyServerService.gql(query: query, variables: {
      'skip': storySkip,
      'take': storyTake,
    });

    final storiesList = jsonResponse['stories'] as List<dynamic>;

    List<String> storyList =
        storiesList.map((e) => e['id'].toString()).toList();
    return await fetchMeshStoryList(storyList);
  }

  @override
  Future<List<NewsListItem>> fetchStoryListByCategorySlug(
    String slug, {
    int storySkip = 0,
    int storyTake = 18,
  }) async {
    const query = '''
        query(
          \$skip: Int,
          \$take: Int,
          \$slug: String,
        ){
          stories(
            take:\$take,
            skip:\$skip,
            orderBy:{
              published_date:desc
            }
            where:{
              source:{
                title:{
                  equals:"READr"
                }
              }
              category:{
                slug:{
                  equals:\$slug
                }
              }
            }
          ){
            id
            title
        }
      }
    
    ''';

    final jsonResponse = await proxyServerService.gql(query: query, variables: {
      'skip': storySkip,
      'take': storyTake,
      'slug': slug,
    });

    final storiesList = jsonResponse['stories'] as List<dynamic>;

    List<String> storyList =
        storiesList.map((e) => e['id'].toString()).toList();
    return await fetchMeshStoryList(storyList);
  }

  @override
  Future<List<NewsListItem>> fetchMeshStoryList(
      List<String> storyIdList) async {
    const String query = '''
    query(
      \$storyIdList: [ID!]
      \$followingMembers: [ID!]
      \$myId: ID
      \$blockAndBlockedIds: [ID!]
    ){
      stories(
        where:{
          source:{
            title:{
              equals: "READr"
            }
          }
          id:{
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
    for (var item in jsonResponse['stories']) {
      newsList.add(NewsListItem.fromJson(item));
    }

    return newsList;
  }
}
