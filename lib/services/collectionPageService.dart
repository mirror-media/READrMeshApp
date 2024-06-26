import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/timelineCollectionPick.dart';

abstract class CollectionPageRepos {
  Future<Map<String, dynamic>> fetchCollectionData(String collectionId,
      {bool useCache = true});
}

class CollectionPageService implements CollectionPageRepos {
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<Map<String, dynamic>> fetchCollectionData(String collectionId,
      {bool useCache = true}) async {
    const String query = """
query(
  \$myId: ID
  \$followingMembers: [ID!]
  \$collectionId: ID
  \$blockAndBlockedIds: [ID!]
){
  collection(
    where:{
      id: \$collectionId
    }
  ){
    format
    summary
    status
    updatedAt
    followingPickMembers: picks(
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
    otherPickMembers: picks(
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
    picksCount(
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
  collectionPicks(
    where:{
      collection:{
        id:{
          equals: \$collectionId
        }
      }
    }
    orderBy:{
      sort_order: asc
    }
  ){
    id
    sort_order
    picked_date
    custom_year
    custom_month
    custom_day
    custom_time
    summary
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
    story{
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
}
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<Comment> allComments = [];
    List<Comment> popularComments = [];

    var collection = jsonResponse['collection'];

    if (collection['comment'].isNotEmpty) {
      allComments = List<Comment>.from(
          collection['comment'].map((element) => Comment.fromJson(element)));
      popularComments.addAll(allComments);
      popularComments.sort((a, b) => b.likedCount.compareTo(a.likedCount));
      popularComments.take(3);
      popularComments.removeWhere((element) => element.likedCount == 0);
    }

    CollectionFormat format = CollectionFormat.folder;
    if (collection['format'] == 'timeline') {
      format = CollectionFormat.timeline;
    }

    List<CollectionPick> collectionPicks = [];
    if (jsonResponse['collectionPicks'].isNotEmpty) {
      switch (format) {
        case CollectionFormat.folder:
          collectionPicks = List<FolderCollectionPick>.from(
              jsonResponse['collectionPicks']
                  .map((element) => FolderCollectionPick.fromJson(element)));
          break;
        case CollectionFormat.timeline:
          collectionPicks = List<TimelineCollectionPick>.from(
              jsonResponse['collectionPicks']
                  .map((element) => TimelineCollectionPick.fromJson(element)));
          break;
      }
    }

    int pickCount = collection['picksCount'];

    List<Member> allPickedMember = [];
    if (BaseModel.checkJsonKeys(collection, ['followingPickMembers']) &&
        collection['followingPickMembers'].isNotEmpty) {
      for (var pick in collection['followingPickMembers']) {
        allPickedMember.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(collection, ['otherPickMembers']) &&
        collection['otherPickMembers'].isNotEmpty) {
      for (var pick in collection['otherPickMembers']) {
        allPickedMember.add(Member.fromJson(pick['member']));
      }
    }

    final controller =
        Get.find<PickableItemController>(tag: 'Collection$collectionId');
    controller.pickCount.value = pickCount;
    controller.commentCount.value = allComments.length;
    controller.pickedMembers.assignAll(allPickedMember);
    if (collection['updatedAt'] != null) {
      controller.collectionUpdatetime.value =
          DateTime.parse(collection['updatedAt']);
    }

    CollectionStatus status = CollectionStatus.publish;
    if (collection['status'] == 'delete') {
      status = CollectionStatus.delete;
    } else if (collection['status'] == 'draft') {
      status = CollectionStatus.draft;
    }

    return {
      'allComments': allComments,
      'popularComments': popularComments,
      'collectionPicks': collectionPicks,
      'status': status,
      'description': collection['summary'],
      'format': format,
    };
  }
}
