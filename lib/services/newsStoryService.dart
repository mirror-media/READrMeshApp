import 'dart:convert';

import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsStoryItem.dart';

class NewsStoryService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String api = Environment().config.readrMeshApi;

  Future<NewsStoryItem> fetchNewsData(String storyId) async {
    const String query = '''
    query(
      \$followingMembers: [ID!]
      \$storyId: ID
      \$myId: ID
    ){
      story(
        where:{
          id: \$storyId
        }
      ){
        id
        title
        content
        full_content
        writer
        source{
          id
          title
        }
        followingPickMembers: pick(
          where:{
            member:{
              id:{
                in: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
            }
            is_active:{
              equals: true
            }
          }
          take: 4
          orderBy:{
            picked_date: desc
          }
        ){
          member{
            id
            nickname
            avatar
          }
        }
        otherPickMembers: pick(
          where:{
            member:{
              id:{
                notIn: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
            }
            is_active:{
              equals: true
            }
          }
          take: 4
          orderBy:{
            picked_date: desc
          }
        ){
          member{
            id
            nickname
            avatar
          }
        }
        pickCount(
          where:{
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
        bookmarkId: pick(
          where:{
            member:{
              id:{
                equals: \$myId
              }
            }
            kind:{
              equals: "bookmark"
            }
            is_active:{
              equals: true
            }
          }
        ){
          id
        }
        comment(
          where:{
            is_active:{
              equals: true
            }
            state:{
              equals: "public"
            }
            member:{
              is_active:{
                equals: true
              }
            }
          }
          orderBy:{
            published_date: desc
          }
        ){
          id
          member{
            id
            nickname
            email
            avatar
          }
          content
          state
          published_date
          likeCount
          is_edited
          isLiked:likeCount(
            where:{
              is_active:{
                equals: true
              }
              id:{
                equals: \$myId
              }
            }
          )
        }
      }
    }
    ''';

    List<String> followingMemberIds = [];
    for (var memberId in UserHelper.instance.currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "storyId": storyId,
      "followingMembers": followingMemberIds,
      "myId": UserHelper.instance.currentUser.memberId,
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

    return NewsStoryItem.fromJson(jsonResponse['data']['story']);
  }
}
