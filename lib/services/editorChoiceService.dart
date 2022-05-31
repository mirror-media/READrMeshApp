import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';

import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItem.dart';

abstract class EditorChoiceRepos {
  Future<List<EditorChoiceItem>> fetchEditorChoiceList();
  Future<List<EditorChoiceItem>> fetchNewsListItemList();
}

class EditorChoiceService implements EditorChoiceRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<EditorChoiceItem>> fetchEditorChoiceList() async {
    const key = 'fetchEditorChoiceList';

    String query = """
    query(
      \$where: EditorChoiceWhereInput, 
      \$first: Int){
      allEditorChoices(
        where: \$where, 
        first: \$first, 
        sortBy: [sortOrder_ASC, createdAt_DESC]
      ) {
        link
        choice {
          id
          style
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"state": "published"},
      "first": 3
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        Get.find<EnvironmentService>().config.readrApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: editorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<EditorChoiceItem> editorChoiceList = [];
    for (int i = 0; i < jsonResponse['data']['allEditorChoices'].length; i++) {
      editorChoiceList.add(EditorChoiceItem.fromJson(
          jsonResponse['data']['allEditorChoices'][i]));
    }
    return editorChoiceList;
  }

  @override
  Future<List<EditorChoiceItem>> fetchNewsListItemList() async {
    const String query = '''
    query(
      \$storyIdList: [String!]
      \$followingMembers: [ID!]
      \$myId: ID
      \$urlList: [String!]
      \$urlFilter: String
      \$readrId: ID
    ){
      stories(
        where:{
          source:{
            id:{
              equals: \$readrId
            }
          }
          url:{
            contains: \$urlFilter
          }
          is_active:{
            equals: true
          }
          OR:[
            {
              content:{
                in: \$storyIdList
              }
            }
            {
              url:{
                in: \$urlList
              }
            }
          ]
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
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<EditorChoiceItem> editorChoiceList = await fetchEditorChoiceList();

    List<String> storyIdList = [];
    List<String> urlList = [];
    for (var element in editorChoiceList) {
      if (element.id != null) {
        storyIdList.add(element.id!);
      }

      if (element.url != null) {
        urlList.add(element.url!);
      }
    }

    Map<String, dynamic> variables = {
      "storyIdList": storyIdList,
      "followingMembers": followingMemberIds,
      "urlList": urlList,
      "myId": Get.find<UserService>().currentUser.memberId,
      "urlFilter": Get.find<EnvironmentService>().config.readrWebsiteLink,
      "readrId": Get.find<EnvironmentService>().config.readrPublisherId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      Get.find<EnvironmentService>().config.readrMeshApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    if (jsonResponse['data']['stories'].isNotEmpty) {
      for (var item in jsonResponse['data']['stories']) {
        NewsListItem news = NewsListItem.fromJson(item);
        int index = editorChoiceList.indexWhere((element) {
          if (element.id != null) {
            return element.id == news.content;
          } else {
            return element.url == news.url;
          }
        });
        if (index != -1) {
          editorChoiceList[index].newsListItem = news;
        }
      }
    }

    editorChoiceList.removeWhere((element) => element.newsListItem == null);
    return editorChoiceList;
  }
}
