import 'dart:convert';

import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String api = Environment().config.readrMeshApi;

  Future<Map<String, dynamic>> fetchHomeScreenData() async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$timeFilter: DateTime
  		\$yesterday: DateTime
      \$followingPublisherIds: [ID!]
      \$myId: ID
      \$readrId: ID
    ){
      followingStories:stories(
        orderBy:{
          published_date: desc
        }
        take: 6
        where:{
          is_active:{
            equals: true
          }
          pick:{
            some:{
              member:{
                id:{
                  in: \$followingMembers
                    not:{
                      equals: \$myId
                    }
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
                picked_date:{
                  gte: \$yesterday
                }
              }
            }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
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
          take: 2
        ){
          picked_date
          member{
            id
            nickname
            avatar
            customId
          }
        }
      }
      latestComments: stories(
        take: 3
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          comment:{
            some:{
              is_active:{
                equals: true
              }
              published_date:{
                gte: \$yesterday
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
                is_active:{
                  equals: true
                }
              }
            }
          }
          source:{
            id:{
              in: \$followingPublisherIds
            }
          }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
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
      allLatestNews: stories(
        take: 10
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          source:{
            id:{
              in: \$followingPublisherIds
          	}
          }
          published_date:{
            gte: \$timeFilter
          }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
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
      followedFollowing:members(
        where:{
          id:{
            notIn: \$followingMembers
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
      RecommendPublisher: publishers(
        where:{
          id:{
            notIn: \$followingPublisherIds
            not:{
              equals: \$readrId
            }
          }
        }
        take: 20
      ){
        id
        title
        logo
        follower(
          where:{
            id:{
              in: \$followingMembers
            }
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
        followerCount(
          where:{
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
    final prefs = await SharedPreferences.getInstance();
    int duration = prefs.getInt('newsCoverage') ?? 24;
    //GQL DateTime must be Iso8601 format
    String timeFilter = DateTime.now()
        .subtract(Duration(hours: duration))
        .toUtc()
        .toIso8601String();
    String yesterday = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toUtc()
        .toIso8601String();

    Member member = UserHelper.instance.currentUser;

    for (var memberId in member.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher in member.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "yesterday": yesterday,
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "myId": member.memberId,
      "timeFilter": timeFilter,
      "readrId": Environment().config.readrPublisherId,
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

    // News list is returned that published in 24 hours, now take 10 first
    List<NewsListItem> allLatestNews = [];
    if (jsonResponse['data']['allLatestNews'].isNotEmpty) {
      for (var item in jsonResponse['data']['allLatestNews']) {
        allLatestNews.add(NewsListItem.fromJson(item));
      }
    }

    // News list that have following members' picks
    List<NewsListItem> followingStories = [];
    if (jsonResponse['data']['followingStories'].isNotEmpty) {
      for (var item in jsonResponse['data']['followingStories']) {
        followingStories.add(NewsListItem.fromJson(item));
      }
      followingStories
          .sort((a, b) => b.latestPickTime!.compareTo(a.latestPickTime!));
    }

    /// News list that don't have following members' picks or comments and have
    /// other members' comments. Now only choose 3 news
    List<NewsListItem> latestComments = [];
    if (jsonResponse['data']['latestComments'].isNotEmpty) {
      for (var item in jsonResponse['data']['latestComments']) {
        latestComments.add(NewsListItem.fromJson(item));
      }
      latestComments.sort((a, b) =>
          b.showComment!.publishDate.compareTo(a.showComment!.publishDate));
    }

    // List of members that followed members' following members
    List<Member> followedFollowing = [];
    if (jsonResponse['data']['followedFollowing'].isNotEmpty) {
      for (var member in jsonResponse['data']['followedFollowing']) {
        followedFollowing.add(Member.followedFollowing(member));
      }
    }

    // List of members that followed same publishers or categories
    // Now take up to 20 members
    List<Member> otherRecommendMembers = [];
    if (jsonResponse['data']['otherRecommendMembers'].isNotEmpty) {
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
    }

    // mix the list and remove repeated members
    List<Member> recommendedMembers = [];
    if (followedFollowing.isEmpty) {
      recommendedMembers = otherRecommendMembers;
    } else {
      recommendedMembers = followedFollowing;
      for (var followedFollowingMember in followedFollowing) {
        otherRecommendMembers.removeWhere(
            (element) => element.memberId == followedFollowingMember.memberId);
      }
      recommendedMembers.addAll(otherRecommendMembers);
    }

    if (recommendedMembers.length < 20 &&
        jsonResponse['data']['otherMembers'].isNotEmpty) {
      for (var item in jsonResponse['data']['otherMembers']) {
        Member member = Member.otherRecommend(item);
        if (!recommendedMembers
            .any((element) => element.memberId == member.memberId)) {
          recommendedMembers.add(member);
        }

        if (recommendedMembers.length >= 20) {
          break;
        }
      }
    }

    List<Publisher> recommendedPublishers = [];
    if (jsonResponse['data']['RecommendPublisher'].isNotEmpty) {
      for (var publisher in jsonResponse['data']['RecommendPublisher']) {
        recommendedPublishers.add(Publisher.fromJson(publisher));
      }
    }

    Map<String, dynamic> result = {
      'allLatestNews': allLatestNews,
      'followingStories': followingStories,
      'latestComments': latestComments,
      'recommendedMembers': recommendedMembers,
      'recommendedPublishers': recommendedPublishers,
    };

    return result;
  }

  Future<List<NewsListItem>> fetchMoreFollowingStories(
    DateTime lastPickTime,
    List<String> alreadyFetchIds,
  ) async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$myId: ID
      \$yesterday: DateTime
      \$lastPickTime: DateTime
      \$alreadyFetchIds: [ID!]
    ){
      stories(
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          id:{
            notIn: \$alreadyFetchIds
          }
          pick:{
            some:{
              member:{
                id:{
                  in: \$followingMembers
                    not:{
                      equals: \$myId
                    }
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
                picked_date:{
                  gte: \$yesterday
                  lt: \$lastPickTime
                }
              }
            }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
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
        followingComment:comment(
          orderBy:{
            published_date: desc
          }
          take: 1
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
              }
            }
          }
        ){
          id
          member{
            id
            nickname
            avatar
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
          take: 2
        ){
          picked_date
          member{
            id
            nickname
            avatar
          }
        }
      }
    }
    """;

    //GQL DateTime must be Iso8601 format
    String yesterday = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toUtc()
        .toIso8601String();

    Member member = UserHelper.instance.currentUser;
    List<String> followingMemberIds = [];
    for (var memberId in member.following) {
      followingMemberIds.add(memberId.memberId);
    }

    Map<String, dynamic> variables = {
      "yesterday": yesterday,
      "followingMembers": followingMemberIds,
      "lastPickTime": lastPickTime.toUtc().toIso8601String(),
      "myId": member.memberId,
      "alreadyFetchIds": alreadyFetchIds
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

    List<NewsListItem> moreFollowingStories = [];
    if (jsonResponse['data']['stories'].isNotEmpty) {
      for (var item in jsonResponse['data']['stories']) {
        moreFollowingStories.add(NewsListItem.fromJson(item));
      }
      moreFollowingStories
          .sort((a, b) => b.latestPickTime!.compareTo(a.latestPickTime!));
    }

    return moreFollowingStories;
  }

  Future<List<NewsListItem>> fetchMoreLatestNews(
    DateTime lastPublishTime,
  ) async {
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
      \$myId: ID
      \$timeFilter: DateTime
      \$followingMembers: [ID!]
      \$lastPublishTime: DateTime
    ){
      stories(
        take: 10
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          published_date:{
            gte: \$timeFilter
            lt: \$lastPublishTime
          }
          source:{
            id:{
              in: \$followingPublisherIds
            }
          }
        }
      ){
        id
        title
        url
        source{
          id
          title
          full_content
          full_screen_ad
        }
        category{
          id
          title
          slug
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
    """;

    final prefs = await SharedPreferences.getInstance();
    int duration = prefs.getInt('newsCoverage') ?? 24;
    //GQL DateTime must be Iso8601 format
    String timeFilter = DateTime.now()
        .subtract(Duration(hours: duration))
        .toUtc()
        .toIso8601String();

    Member member = UserHelper.instance.currentUser;

    List<String> followingMemberIds = [];
    for (var memberId in member.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<String> followingPublisherIds = [];
    for (var publisher in member.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "timeFilter": timeFilter,
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "myId": member.memberId,
      "lastPublishTime": lastPublishTime.toUtc().toIso8601String(),
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

    List<NewsListItem> moreLatestNews = [];
    if (jsonResponse['data']['stories'].isNotEmpty) {
      for (var item in jsonResponse['data']['stories']) {
        moreLatestNews.add(NewsListItem.fromJson(item));
      }
    }

    return moreLatestNews;
  }
}
