import 'package:get/get.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/newsStoryItem.dart';

abstract class NewsStoryRepos {
  Future<NewsStoryItem> fetchNewsData(String storyId);
}

class NewsStoryService implements NewsStoryRepos {
  final ProxyServerService proxyServerService = Get.find();

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
        related(
          where:{
            is_active:{
              equals: true
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

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    return NewsStoryItem.fromJson(jsonResponse['story']);
  }
}
