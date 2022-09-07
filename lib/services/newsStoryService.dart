import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsStoryItem.dart';

abstract class NewsStoryRepos {
  Future<NewsStoryItem> fetchNewsData(String storyId);
}

class NewsStoryService implements NewsStoryRepos {
  @override
  Future<NewsStoryItem> fetchNewsData(String storyId) async {
    const String query = '''
    query(
      \$followingMembers: [ID!]
      \$storyId: ID
      \$myId: ID
      \$blockAndBlockedIds: [ID!]
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
            avatar_image{
              id
              resized{
                original
              }
            }
          }
        }
        otherPickMembers: pick(
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
              id:{
                notIn: \$blockAndBlockedIds
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
            avatar_image{
              id
              resized{
                original
              }
            }
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
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "storyId": storyId,
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    return NewsStoryItem.fromJson(jsonResponse.data!['story']);
  }
}
