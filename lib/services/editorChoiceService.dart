import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItem.dart';

class EditorChoiceServices {
  final ApiBaseHelper _helper = ApiBaseHelper();

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
        key, Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
        maxAge: editorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<EditorChoiceItem> editorChoiceList = [];
    for (int i = 0; i < jsonResponse['data']['allEditorChoices'].length; i++) {
      editorChoiceList.add(EditorChoiceItem.fromJson(
          jsonResponse['data']['allEditorChoices'][i]));
    }
    return editorChoiceList;
  }

  Future<List<EditorChoiceItem>> fetchNewsListItemList() async {
    const String query = '''
    query(
      \$storyIdList: [String!]
      \$followingMembers: [ID!]
      \$myId: ID
      \$urlList: [String!]
      \$urlFilter: String
    ){
      stories(
        where:{
          source:{
            title:{
              equals: "readr"
            }
          }
          url:{
            contains: \$urlFilter
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
    for (var memberId in UserHelper.instance.currentUser.following) {
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
      "myId": UserHelper.instance.currentUser.memberId,
      "urlFilter": Environment().config.readrWebsiteLink,
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
