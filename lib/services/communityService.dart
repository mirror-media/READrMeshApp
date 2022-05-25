import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

abstract class CommunityRepos {
  Future<List<NewsListItem>> fetchFollowingPickedNews(
      {List<String>? alreadyFetchStoryIds});
  Future<List<NewsListItem>> fetchMoreFollowingPickedNews(
      List<String> alreadyFetchStoryIds);
  Future<List<NewsListItem>> fetchLatestCommentNews(
      {List<String>? alreadyFetchStoryIds, int needAmount = 3});
  Future<List<Member>> fetchRecommendMembers();
}

class CommunityService implements CommunityRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String _api = Get.find<EnvironmentService>().config.readrMeshApi;

  @override
  Future<List<NewsListItem>> fetchFollowingPickedNews(
      {List<String>? alreadyFetchStoryIds}) async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$myId: ID
      \$alreadyFetchStoryIds: [ID!]
    ){
      picks(
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
    }
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "alreadyFetchStoryIds": alreadyFetchStoryIds ?? [],
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

    List<NewsListItem> followingPickedNews = [];
    for (var item in jsonResponse['data']['picks']) {
      NewsListItem newsListItem = NewsListItem.fromJson(item['story']);
      followingPickedNews.addIf(
          !followingPickedNews.any((element) => element.id == newsListItem.id),
          newsListItem);
    }

    if (followingPickedNews.length < 10 && followingPickedNews.isNotEmpty) {
      List<String> fetchedStoryIds = List<String>.from(followingPickedNews.map(
        (e) => e.id,
      ));
      if (alreadyFetchStoryIds != null) {
        fetchedStoryIds.addAll(alreadyFetchStoryIds);
      }
      followingPickedNews
          .addAll(await fetchMoreFollowingPickedNews(fetchedStoryIds));
    }

    return followingPickedNews;
  }

  @override
  Future<List<NewsListItem>> fetchMoreFollowingPickedNews(
      List<String> alreadyFetchStoryIds) async {
    return await fetchFollowingPickedNews(
        alreadyFetchStoryIds: alreadyFetchStoryIds);
  }

  @override
  Future<List<NewsListItem>> fetchLatestCommentNews(
      {List<String>? alreadyFetchStoryIds, int needAmount = 3}) async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$myId: ID
      \$alreadyFetchStoryIds: [ID!]
      \$followingPublisherIds: [ID!]
    ){
      comments(
        take: 10
        orderBy: [{published_date: desc}],
        where:{
          is_active:{
            equals: true
          },
          state:{
            equals: "public"
          },
          member:{
            id:{
              notIn: \$followingMembers,
              not:{
                equals: \$myId
              }
            }
          },
          story:{
            id:{
              notIn: \$alreadyFetchStoryIds
            },
            is_active:{
              equals: true
            },
            source:{
              id:{
                in: \$followingPublisherIds
              }
            }
          }
        }
      ){
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
            }
          )
          notFollowingComment:comment(
            take: 1
            orderBy:{
              published_date: desc
            }
            where:{
              is_active:{
                equals: true
              }
              state:{
                equals: "public"
              }
              member:{
                id:{
                  notIn: \$followingMembers
                  not:{
                    equals: \$myId
                  }
                }
              }
            }
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

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<String> followingPublisherIds = [];
    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "alreadyFetchStoryIds": alreadyFetchStoryIds ?? [],
      "followingPublisherIds": followingPublisherIds,
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

    List<NewsListItem> latestCommentNews = [];
    for (var item in jsonResponse['data']['comments']) {
      NewsListItem newsListItem = NewsListItem.fromJson(item['story']);
      latestCommentNews.addIf(
          !latestCommentNews.any((element) => element.id == newsListItem.id),
          newsListItem);
      if (latestCommentNews.length == needAmount) {
        break;
      }
    }

    if (latestCommentNews.length < needAmount && latestCommentNews.isNotEmpty) {
      List<String> fetchedStoryIds = List<String>.from(latestCommentNews.map(
        (e) => e.id,
      ));
      if (alreadyFetchStoryIds != null) {
        fetchedStoryIds.addAll(alreadyFetchStoryIds);
      }
      latestCommentNews.addAll(await fetchLatestCommentNews(
        alreadyFetchStoryIds: fetchedStoryIds,
        needAmount: needAmount - latestCommentNews.length,
      ));
    }

    return latestCommentNews;
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
}
