import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItemList.dart';
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
      stories(
        where:{
          published_date:{
            gte: \$yesterday
          }
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
        orderBy:{
          published_date: desc
        }
      ){
        id
        title
        url
        summary
        content
        source{
          id
          title
        }
        category{
          id
          title
          slug
        }
        published_date
        og_image
        paywall
        full_screen_ad
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
              notIn: "private"
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
          }
        }
        myComments: comment(
          where:{
            member:{
              is_active: {
                equals: true
              }
              id:{
                equals: \$myId
              }
            }
            state:{
              notIn: "private"
            }
            is_active:{
              equals: true
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
          }
          content
          state
          published_date
        }
        followingComments: comment(
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
              notIn: "private"
            }
            is_active:{
              equals: true
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
        otherComments: comment(
          where:{
            member:{
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
            state:{
              in: "public"
            }
            is_active:{
              equals: true
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
            in: \$followingMembers
          }
          is_active: {
            equals: true
          }
        }
      ){
        id
        nickname
        following(
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
        ){
          id
          nickname
          followerCount
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
        nickname: "Anonymous user",
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

    // News list is returned that published in 24 hours
    NewsListItemList allNewsList = NewsListItemList();

    // News list that have following members' picks or comments
    NewsListItemList followingNewsList = NewsListItemList();

    /// News list that don't have following members' picks or comments and have
    /// other members' comments. Now only choose 3 news
    NewsListItemList latestCommentsNewsList = NewsListItemList();

    // temp list put the news have other comments
    NewsListItemList tempNewsList = NewsListItemList();

    if (jsonResponse['data']['stories'].isNotEmpty) {
      allNewsList = NewsListItemList.fromJson(jsonResponse['data']['stories']);
      for (var news in allNewsList) {
        if (news.followingPickMembers.isNotEmpty ||
            news.followingComments.isNotEmpty) {
          followingNewsList.add(news);
        }

        // if news have other comments, add to temp news list
        if (news.otherComments.isNotEmpty) {
          tempNewsList.add(news);
        }
      }

      /// sort the list by comment publish date, because GQL already sort
      /// comments in each news so only compare first comment
      tempNewsList.sort((a, b) => b.otherComments[0].publishDate
          .compareTo(a.otherComments[0].publishDate));

      // take first three news put into latestCommentsNewsList
      for (int i = 0; i < 3 && i < tempNewsList.length; i++) {
        latestCommentsNewsList.add(tempNewsList[i]);
      }
    }

    // List of members that followed members' following members
    List<Member> followedFollowing = [];
    if (jsonResponse['data']['followedFollowing'].isNotEmpty) {
      for (var followedMember in jsonResponse['data']['followedFollowing']) {
        if (followedMember['following'].isNotEmpty) {
          for (var followingMember in followedMember['following']) {
            followedFollowing.add(Member.followedFollowing(followingMember,
                followedMember['id'], followedMember['nickname']));
          }
        }
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
        int num = b.commentCount!.compareTo(a.commentCount!);
        if (num != 0) return num;
        return b.pickCount!.compareTo(a.pickCount!);
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
      'followingNewsList': followingNewsList,
      'latestCommentsNewsList': latestCommentsNewsList,
      'allNewsList': allNewsList,
      'recommendedMembers': recommendedMembers,
      'member': member,
    };

    return result;
  }
}
