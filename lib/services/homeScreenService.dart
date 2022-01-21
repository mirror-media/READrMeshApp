import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/memberService.dart';

class HomeScreenService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;
  final MemberService _memberService = MemberService();

  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null) {
      headers.addAll({"Authorization": "Bearer $token"});
    }

    return headers;
  }

  // Get News selet CMS User token for authorization
  // TODO: Delete when verify firebase token is finished
  Future<String> _fetchCMSUserToken() async {
    String mutation = """
    mutation(
	    \$email: String!,
	    \$password: String!
    ){
	    authenticateUserWithPassword(
		    email: \$email
		    password: \$password
      ){
        ... on UserAuthenticationWithPasswordSuccess{
        	sessionToken
      	}
        ... on UserAuthenticationWithPasswordFailure{
          message
      	}
      }
    }
    """;

    Map<String, String> variables = {
      "email": DevConfig().appHelperEmail,
      "password": DevConfig().appHelperPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

  Future<Map<String, dynamic>> fetchHomeScreenData() async {
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$yesterday: DateTime
      \$followingCategorySlugs: [String!]
      \$followingPublisherIds: [ID!]
      \$myId: ID
    ){
      followingStories:stories(
        orderBy:{
          published_date: desc
        }
        take: 5
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
                  is_active:{
                    equals: true
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
              is_active:{
                equals: true
              }
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
        allComments: comment(
          orderBy:{
            published_date: desc
          }
          take: 10
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
              is_active: {
                equals: true
              }
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
          OR:[
            {
              source:{
                id:{
                  in: \$followingPublisherIds
              }
              }
            }
            {
              category:{
                slug:{
                  in: \$followingCategorySlugs
                }
              }
            }
          ]
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
        notFollowingComment:comment(
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
              is_active:{
                equals: true
              }
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
        allComments: comment(
          orderBy:{
            published_date: desc
          }
          take: 10
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
          OR:[
            {
              source:{
                id:{
                  in: \$followingPublisherIds
              }
              }
            }
            {
              category:{
                slug:{
                  in: \$followingCategorySlugs
                }
              }
            }
          ]
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
              is_active: {
                equals: true
              }
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
              is_active: {
                equals: true
              }
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
            member:{
              is_active: {
                equals: true
              }
            }
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
            member:{
              is_active: {
                equals: true
              }
            }
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
          OR:[
            {
              follow_publisher:{
                some:{
                  id:{
                    in: \$followingPublisherIds
                  }
                }
              }
            },
            {
              following_category:{
                some:{
                  slug:{
                    in: \$followingCategorySlugs
                  }
                }
              }
            }
          ]
        }
        take: 20
      ){
        id
        nickname
        avatar
        followerCount
        follower(take:1){
          id
          nickname
        }
        pickCount(
          where:{
            picked_date:{
              gte: \$yesterday
            }
          }
        )
        commentCount(
          where:{
            published_date:{
              gte: \$yesterday
            }
          }
        )
      }
    }
    """;

    List<String> followingMemberIds = [];
    List<String> followingCategorySlugs = [];
    List<String> followingPublisherIds = [];
    late Member member;
    //GQL DateTime must be Iso8601 format
    String yesterday = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toUtc()
        .toIso8601String();
    // TODO: Remove test data time
    yesterday = DateTime(2021, 1, 1).toUtc().toIso8601String();

    if (FirebaseAuth.instance.currentUser != null) {
      // fetch user following members, categories, publishers, and member id
      member = await _memberService.fetchMemberData();

      for (var memberId in member.following!) {
        followingMemberIds.add(memberId.memberId);
      }

      for (var category in member.followingCategory!) {
        followingCategorySlugs.add(category.slug);
      }

      for (var publisher in member.followingPublisher!) {
        followingPublisherIds.add(publisher.id);
      }
    } else {
      // fetch local publisher id and category slug
      // TODO: Change to use local data after choose UI is available
      member = Member(
        nickname: "匿名使用者",
        memberId: "-1",
      );
      followingCategorySlugs = ['unclassified'];
      followingPublisherIds = ['1', '2', '3'];
    }

    Map<String, dynamic> variables = {
      "yesterday": yesterday,
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "followingCategorySlugs": followingCategorySlugs,
      "myId": member.memberId,
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

    // News list that have following members' picks or comments
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

    Map<String, dynamic> result = {
      'allLatestNews': allLatestNews,
      'followingStories': followingStories,
      'latestComments': latestComments,
      'recommendedMembers': recommendedMembers,
      'member': member,
    };

    return result;
  }
}
