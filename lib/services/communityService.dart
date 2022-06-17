import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';

abstract class CommunityRepos {
  Future<List<CommunityListItem>> fetchFollowingPicked(
      {List<String>? alreadyFetchStoryIds,
      List<String>? alreadyFetchCollectionIds});
  Future<List<CommunityListItem>> fetchFollowingComment(
      {List<String>? alreadyFetchStoryIds,
      List<String>? alreadyFetchCollectionIds});
  Future<List<Member>> fetchRecommendMembers();
  Future<List<CommunityListItem>> fetchNewCollection(
      {List<String>? alreadyFetchCollectionIds});
}

class CommunityService implements CommunityRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String _api = Get.find<EnvironmentService>().config.readrMeshApi;

  @override
  Future<List<CommunityListItem>> fetchFollowingPicked(
      {List<String>? alreadyFetchStoryIds,
      List<String>? alreadyFetchCollectionIds}) async {
    const String query = """
query(
  \$followingMembers: [ID!]
  \$myId: ID
  \$alreadyFetchStoryIds: [ID!]
  \$alreadyFetchCollectionIds: [ID!]
){
  storyPicks: picks(
    orderBy: [{picked_date: desc}],
    take: 20,
    where:{
      is_active:{
        equals: true
      },
      state:{
        equals: "public"
      },
      kind:{
        equals: "read"
      },
      member:{
        id:{
          in: \$followingMembers
          not:{
            equals: \$myId
          }
        }
      },
      story:{
        id:{
          notIn: \$alreadyFetchStoryIds
        }
        is_active:{
          equals: true
        }
      }
    }
  ){
    picked_date
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
      og_image
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
          }
        }
      )
      followingPickComment: pick(
        where:{
          is_active:{
            equals: true
          }
          member:{
            is_active:{
              equals: true
            }
            id:{
              in: \$followingMembers
            }
          }
        }
        orderBy:{
          picked_date: desc
        }
      ){
        pick_comment(
          where:{
            is_active:{
              equals: true
            }
            state:{
              equals: "public"
            }
          }
          orderBy:{
            published_date: desc
          }
          take: 1
        ){
          id
          member{
            id
            nickname
            avatar
            customId
          }
          content
          published_date
        }
      }
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
        picked_date
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
  collectionPicks: picks(
    orderBy: [{picked_date: desc}],
    take: 20,
    where:{
      is_active:{
        equals: true
      },
      state:{
        equals: "public"
      },
      kind:{
        equals: "read"
      },
      member:{
        id:{
          in: \$followingMembers
          not:{
            equals: \$myId
          }
        }
      },
      collection:{
        status:{
          equals: "publish"
        }
        id:{
          notIn: \$alreadyFetchCollectionIds
        }
      }
    }
  ){
    picked_date
    collection{
      id
      title
      slug
      status
      creator{
        id
        nickname
        avatar
        customId
      }
      heroImage{
        id
        urlOriginal
        file{
          url
        }
      }
      format
      createdAt
      picksCount(
        where:{
          state:{
            in: "public"
          }
          is_active:{
            equals: true
          }
        }
      )
      myPickId: picks(
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
          }
        }
      )
      followingPickComment: picks(
        where:{
          is_active:{
            equals: true
          }
          member:{
            is_active:{
              equals: true
            }
            id:{
              in: \$followingMembers
            }
          }
        }
        orderBy:{
          picked_date: desc
        }
      ){
        pick_comment(
          where:{
            is_active:{
              equals: true
            }
            state:{
              equals: "public"
            }
          }
          orderBy:{
            published_date: desc
          }
          take: 1
        ){
          id
          member{
            id
            nickname
            avatar
            customId
          }
          content
          published_date
        }
      }
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
        picked_date
        member{
          id
          nickname
          avatar
          customId
        }
      }
      otherPicks:picks(
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
    }
  }
}
    """;

    Map<String, dynamic> variables = {
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "alreadyFetchStoryIds": alreadyFetchStoryIds ?? [],
      "alreadyFetchCollectionIds": alreadyFetchCollectionIds ?? []
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<CommunityListItem> followingPicked = [];
    for (var item in jsonResponse['data']['storyPicks']) {
      CommunityListItem pickItem = CommunityListItem.fromJson(item);
      followingPicked.addIf(
        !followingPicked.any(
            (element) => element.newsListItem?.id == pickItem.newsListItem!.id),
        pickItem,
      );
    }
    for (var item in jsonResponse['data']['collectionPicks']) {
      CommunityListItem pickItem = CommunityListItem.fromJson(item);
      followingPicked.addIf(
        !followingPicked.any(
            (element) => element.collection?.id == pickItem.collection!.id),
        pickItem,
      );
    }

    return followingPicked;
  }

  @override
  Future<List<CommunityListItem>> fetchFollowingComment(
      {List<String>? alreadyFetchStoryIds,
      List<String>? alreadyFetchCollectionIds}) async {
    const String query = """
query(
  \$followingMembers: [ID!]
  \$myId: ID
  \$alreadyFetchStoryIds: [ID!]
  \$alreadyFetchCollectionIds: [ID!]
){
  storyComments: comments(
    orderBy: [{published_date: desc}],
    take: 20,
    where:{
      is_active:{
        equals: true
      },
      state:{
        equals: "public"
      },
      member:{
        id:{
          in: \$followingMembers
          not:{
            equals: \$myId
          }
        }
      },
      story:{
        id:{
          notIn: \$alreadyFetchStoryIds
        }
        is_active:{
          equals: true
      	}
      }
    }
  ){
    published_date
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
      og_image
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
          }
        }
      )
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
        picked_date
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
      comment(
        where:{
          is_active:{
            equals: true
          }
          state:{
            equals: "public"
          }
          member:{
            id:{
              in: \$followingMembers
              not:{
                equals: \$myId
              }
            }
          }
        }
        orderBy:{
          published_date: desc
        }
        take: 2
      ){
        id
        member{
          id
          nickname
          avatar
          customId
        }
        content
      	state
        published_date
        likeCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
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
  collectionComments: comments(
    orderBy: [{published_date: desc}],
    take: 20,
    where:{
      is_active:{
        equals: true
      },
      state:{
        equals: "public"
      },
      member:{
        id:{
          in: \$followingMembers
          not:{
            equals: \$myId
          }
        }
      },
      collection:{
        status:{
          equals: "publish"
        }
        id:{
        	notIn: \$alreadyFetchCollectionIds
        }
      }
    }
  ){
    published_date
    collection{
      id
      title
      slug
      status
      creator{
        id
        nickname
        avatar
        customId
      }
      heroImage{
        id
        urlOriginal
        file{
          url
        }
      }
      format
      createdAt
      picksCount(
        where:{
          state:{
            in: "public"
          }
          is_active:{
            equals: true
          }
        }
      )
      myPickId: picks(
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
        picked_date
        member{
          id
          nickname
          avatar
          customId
        }
      }
      otherPicks:picks(
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
      comment(
        where:{
          is_active:{
            equals: true
          }
          state:{
            equals: "public"
          }
          member:{
            id:{
              in: \$followingMembers
              not:{
                equals: \$myId
              }
            }
          }
        }
        orderBy:{
          published_date: desc
        }
        take: 2
      ){
        id
        member{
          id
          nickname
          avatar
          customId
        }
        content
      	state
        published_date
        likeCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
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
}
    """;

    Map<String, dynamic> variables = {
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "alreadyFetchStoryIds": alreadyFetchStoryIds ?? [],
      "alreadyFetchCollectionIds": alreadyFetchCollectionIds ?? []
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<CommunityListItem> followingComment = [];
    for (var item in jsonResponse['data']['storyComments']) {
      CommunityListItem commentItem = CommunityListItem.fromJson(item);
      followingComment.addIf(
        !followingComment.any((element) =>
            element.newsListItem?.id == commentItem.newsListItem!.id),
        commentItem,
      );
    }
    for (var item in jsonResponse['data']['collectionComments']) {
      CommunityListItem commentItem = CommunityListItem.fromJson(item);
      followingComment.addIf(
        !followingComment.any(
            (element) => element.collection?.id == commentItem.collection!.id),
        commentItem,
      );
    }

    return followingComment;
  }

  @override
  Future<List<Member>> fetchRecommendMembers() async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$myId: ID
      \$followingPublisherIds: [ID!]
      \$yesterday: DateTime
    ){
      followedFollowing:members(
        orderBy:[{id: desc}]
        where:{
          id:{
            notIn: \$followingMembers
            not:{
              equals: \$myId
            }
          }
          follower:{
            some:{
              id:{
                in: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
            }
          }
          is_active: {
            equals: true
          }
        }
      ){
        id
        nickname
        avatar
        customId
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        follower(
          where:{
            is_active:{
              equals: true
            }
            id:{
              in: \$followingMembers
            }
          }
          take: 1
        ){
          id
          nickname
          customId
        }
      }
      otherRecommendMembers:members(
        where:{
          id:{
            notIn: \$followingMembers
            not:{
              equals: \$myId
            }
          }
          is_active: {
            equals: true
          }
          follow_publisher:{
            some:{
              id:{
                in: \$followingPublisherIds
              }
            }
          }
        }
        take: 20
      ){
        id
        nickname
        avatar
        customId
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        follower(
          where:{
            is_active:{
              equals: true
            }
          }
          take: 1
        ){
          id
          nickname
          customId
        }
        pickCount(
          where:{
            picked_date:{
              gte: \$yesterday
            }
            is_active:{
              equals: true
            }
          }
        )
        commentCount(
          where:{
            published_date:{
              gte: \$yesterday
            }
            is_active:{
              equals: true
            }
          }
        )
      }
      otherMembers:members(
        orderBy: [{id: desc}]
        where:{
          id:{
            notIn: \$followingMembers
            not:{
              equals: \$myId
            }
          }
          is_active: {
            equals: true
          }
        }
        take: 20
      ){
        id
        nickname
        avatar
        customId
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        follower(
          where:{
            is_active:{
              equals: true
            }
          }
          take: 1
        ){
          id
          nickname
          customId
        }
        pickCount(
          where:{
            picked_date:{
              gte: \$yesterday
            }
            is_active:{
              equals: true
            }
          }
        )
        commentCount(
          where:{
            published_date:{
              gte: \$yesterday
            }
            is_active:{
              equals: true
            }
          }
        )
      }
    }
    """;

    List<String> followingMemberIds = [];
    List<String> followingPublisherIds = [];

    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    String yesterday = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toUtc()
        .toIso8601String();

    Map<String, dynamic> variables = {
      "yesterday": yesterday,
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<Member> recommendMembers = [];
    if (jsonResponse['data']['followedFollowing'].isNotEmpty) {
      for (var member in jsonResponse['data']['followedFollowing']) {
        Member recommendMember = Member.followedFollowing(member);
        recommendMembers.addIf(
            !recommendMembers
                .any((element) => element.memberId == recommendMember.memberId),
            recommendMember);
      }
    }

    if (jsonResponse['data']['otherRecommendMembers'].isNotEmpty &&
        recommendMembers.length < 20) {
      List<Member> otherRecommendMembers = [];
      for (var otherRecommend in jsonResponse['data']
          ['otherRecommendMembers']) {
        otherRecommendMembers.add(Member.otherRecommend(otherRecommend));
      }
      // sort by amount of comments and picks in last 24 hours
      otherRecommendMembers.sort((a, b) {
        int num = b.pickCount!.compareTo(a.pickCount!);
        if (num != 0) return num;
        return b.commentCount!.compareTo(a.commentCount!);
      });

      for (var item in otherRecommendMembers) {
        recommendMembers.addIf(
            !recommendMembers
                .any((element) => element.memberId == item.memberId),
            item);
        if (recommendMembers.length == 20) {
          break;
        }
      }
    }

    if (recommendMembers.length < 20 &&
        jsonResponse['data']['otherMembers'].isNotEmpty) {
      for (var item in jsonResponse['data']['otherMembers']) {
        Member member = Member.otherRecommend(item);
        if (!recommendMembers
            .any((element) => element.memberId == member.memberId)) {
          recommendMembers.add(member);
        }

        if (recommendMembers.length >= 20) {
          break;
        }
      }
    }

    return recommendMembers;
  }

  @override
  Future<List<CommunityListItem>> fetchNewCollection(
      {List<String>? alreadyFetchCollectionIds}) async {
    const String query = """
query(
  \$myId: ID
  \$followingMembers: [ID!]
  \$alreadyFetchCollectionIds: [ID!]
){
  collections(
    where:{
			status:{
        equals: "publish"
      }
      id:{
        notIn: \$alreadyFetchCollectionIds
      }
      creator:{
        id:{
          in: \$followingMembers
        }
      }
    }
    orderBy:[{createdAt: desc}]
    take:20
  ){
    id
    title
    slug
    status
    creator{
      id
      nickname
      avatar
      customId
    }
    heroImage{
      id
      urlOriginal
      file{
        url
      }
    }
    format
    createdAt
    picksCount(
      where:{
        state:{
          in: "public"
        }
        is_active:{
          equals: true
        }
      }
    )
    myPickId: picks(
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
      picked_date
      member{
        id
        nickname
        avatar
        customId
      }
    }
    otherPicks:picks(
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
  }
}
""";

    Map<String, dynamic> variables = {
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "alreadyFetchCollectionIds": alreadyFetchCollectionIds ?? []
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<CommunityListItem> newCollection = [];
    for (var item in jsonResponse['data']['collections']) {
      CommunityListItem commentItem = CommunityListItem.fromJson(item);
      newCollection.addIf(
        !newCollection.any(
            (element) => element.collection?.id == commentItem.collection!.id),
        commentItem,
      );
    }

    return newCollection;
  }
}
