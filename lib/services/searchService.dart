import 'package:get/get.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/newsListItem.dart';

abstract class SearchRepos {
  Future<List<NewsListItem>> fetchNewsByIdList(List<int> idList);

  Future<List<Collection>> fetchCollectionsByIdList(List<int> idList);
}

class SearchService implements SearchRepos {
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<List<NewsListItem>> fetchNewsByIdList(List<int> idList) async {
    const String query = """
    query(
      \$idList: [ID!]
      \$followingMembers: [ID!]
      \$myId: ID
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
          id:{
            in: \$idList
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
              is_active:{
                equals: true
              }
              id:{
                notIn: \$blockAndBlockedIds
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
              is_active:{
                equals: true
              }
              id:{
                notIn: \$blockAndBlockedIds
              }
            }
          }
        )
      }
    }
    """;

    Map<String, dynamic> variables = {
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "idList": idList,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final response =
        await proxyServerService.gql(query: query, variables: variables);

    List<NewsListItem> allNewsResult = [];
    for (var item in response.data!['stories']) {
      allNewsResult.add(NewsListItem.fromJson(item));
    }

    allNewsResult.sort((a, b) => idList
        .indexWhere((element) => element.toString() == a.id)
        .compareTo(idList.indexWhere((element) => element.toString() == b.id)));

    return allNewsResult;
  }

  @override
  Future<List<Collection>> fetchCollectionsByIdList(List<int> idList) async {
    const String query = """
    query(
      \$idList: [ID!]
      \$followingMembers: [ID!]
      \$myId: ID
      \$blockAndBlockedIds: [ID!]
    ){
      collections(
        where:{
          id:{
            in: \$idList
          }
          status:{
            equals: "publish"
          }
          creator:{
            id:{
              notIn: \$blockAndBlockedIds
            }
          }
        }
        orderBy:{
          createdAt: desc
        }
      ){
        id
        title
        slug
        public
        status
        creator{
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
        heroImage{
          id
          resized{
            original
          }
        }
        format
        createdAt
        commentCount(
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
        )
        followingPicks: picks(
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
        otherPicks:picks(
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
        picksCount(
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

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "idList": idList,
      "myId": Get.find<UserService>().currentUser.memberId,
      "followingMembers": followingMemberIds,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<Collection> allCollectionResult = List<Collection>.from(jsonResponse
        .data!['collections']
        .map((element) => Collection.fromJson(element)));
    allCollectionResult.sort((a, b) => idList
        .indexWhere((element) => element.toString() == a.id)
        .compareTo(idList.indexWhere((element) => element.toString() == b.id)));

    return allCollectionResult;
  }
}
