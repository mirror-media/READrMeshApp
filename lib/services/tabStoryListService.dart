import 'dart:convert';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
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
  final ApiBaseHelper _helper = ApiBaseHelper();
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
    String key =
        'fetchStoryList?storySkip=$storySkip&storyFirst=$storyFirst&projectSkip=$projectSkip&projectFirst=$projectFirst';

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

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storySkip > 30) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
          key, Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    List<String> storyList = [];
    List<String> projectList = [];
    for (var item in jsonResponse['data']['story']) {
      _fetchedStoryIdList.add(item['id']);
      storyList.add(item['id']);
    }

    for (var item in jsonResponse['data']['project']) {
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
    String key =
        'fetchStoryListByCategorySlug?slug=$slug&storySkip=$storySkip&storyFirst=$storyFirst&projectSkip=$projectSkip&projectFirst=$projectFirst';

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

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (storySkip > 30) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
          key, Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    List<String> storyList = [];
    List<String> projectList = [];
    for (var item in jsonResponse['data']['story']) {
      _fetchedStoryIdList.add(item['id']);
      storyList.add(item['id']);
    }

    for (var item in jsonResponse['data']['project']) {
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
        }
        orderBy:{
          published_date: desc
        }
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
    ''';

    List<String> followingMemberIds = [];
    for (var memberId in UserHelper.instance.currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "storyIdList": storyIdList,
      "followingMembers": followingMemberIds,
      "myId": UserHelper.instance.currentUser.memberId,
      "urlFilter": Environment().config.readrWebsiteLink,
      "readrId": Environment().config.readrPublisherId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      Environment().config.readrMeshApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<NewsListItem> newsList = [];
    for (var item in jsonResponse['data']['stories']) {
      newsList.add(NewsListItem.fromJson(item));
    }

    return newsList;
  }
}
