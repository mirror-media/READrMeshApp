import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItemList.dart';

class HomeScreenService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  static Map<String, String> getHeaders(String token) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    headers.addAll({"Authorization": "Bearer $token"});

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
		    token
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
        jsonResponse['data']['authenticateUserWithPassword']['token'];

    return token;
  }

  Future<Map<String, dynamic>> fetchMemberFollowing() async {
    const String query = """
    query(
      \$firebaseId: String
    ){
      members(
        where:{
          firebaseId: {
            equals: \$firebaseId
          }
        }
      ){
        id
        following(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
        }
        following_category{
          slug
        }
        follow_publisher{
          id
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "firebaseId": FirebaseAuth.instance.currentUser!.uid,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    String token = await _fetchCMSUserToken();
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: getHeaders(token),
    );

    List<String> followingMemberIds = [];
    List<String> followingCategorySlugs = [];
    List<String> followingPublisherIds = [];
    String myId = '';
    if (jsonResponse['data']['members'].isNotEmpty) {
      var member = jsonResponse['data']['members'];
      myId = member['id'];
      if (member['following'].isNotEmpty) {
        for (var followingMember in member['following']) {
          followingMemberIds.add(followingMember['id']);
        }
      }

      if (member['following_category'].isNotEmpty) {
        for (var followingCategory in member['following_category']) {
          followingCategorySlugs.add(followingCategory['slug']);
        }
      }

      if (member['follow_publisher'].isNotEmpty) {
        for (var followingPublisher in member['follow_publisher']) {
          followingPublisherIds.add(followingPublisher['id']);
        }
      }
    }

    Map<String, dynamic> memberFollowing = {
      'followingMemberIds': followingMemberIds,
      'followingCategorySlugs': followingCategorySlugs,
      'followingPublisherIds': followingPublisherIds,
      'myId': myId,
    };
    return memberFollowing;
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
          source:{
            id:{
              in: \$followingPublisherIds
            }
          }
          category:{
            slug:{
              in: \$followingCategorySlugs
            }
          }
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
                  equals:\$myId
                }
              }
            }
            state:{
              in: "public"
            }
            kind:{
              equals: "read"
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
          }
          take:1
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
        otherComments: comment(
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
          }
          take:1
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
          OR:{
            follow_publisher:{
              some:{
                id:{
                  in: \$followingPublisherIds
                }
              }
            }
            following_category:{
              some:{
                slug:{
                  in: \$followingCategorySlugs
                }
              }
            }
          }
        }
        take: 20
      ){
        id
        nickname
        followerCount
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
    // myId must has value, so set it to 0
    String myId = "0";
    //GQL DateTime must be Iso8601 format
    String yesterday = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toUtc()
        .toIso8601String();
    // TODO: Remove test data time
    yesterday = DateTime(2021, 1, 1).toUtc().toIso8601String();

    if (FirebaseAuth.instance.currentUser != null) {
      // fetch user following members, categories, publishers, and member id
      Map<String, dynamic> memberFollowing = await fetchMemberFollowing();

      followingMemberIds = memberFollowing['followingMemberIds']!;
      followingCategorySlugs = memberFollowing['followingCategorySlugs']!;
      followingPublisherIds = memberFollowing['followingPublisherIds']!;
      myId = memberFollowing['myId']!;
    } else {
      // fetch local publisher id and category slug
      // TODO: Change to use local data after choose UI is available
      followingCategorySlugs = ['unclassified'];
      followingPublisherIds = ['1', '2'];
    }

    Map<String, dynamic> variables = {
      "yesterday": yesterday,
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "followingCategorySlugs": followingCategorySlugs,
      "myId": myId,
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

    // News that is not put into above list
    NewsListItemList otherNewsList = NewsListItemList();

    if (jsonResponse['data']['stories'].isNotEmpty) {
      allNewsList = NewsListItemList.fromJson(jsonResponse['data']['stories']);
      for (var news in allNewsList) {
        if (news.followingPickMembers.isNotEmpty ||
            news.followingComments.isNotEmpty) {
          followingNewsList.add(news);
        } else if (news.otherComments.isNotEmpty &&
            latestCommentsNewsList.length < 3) {
          latestCommentsNewsList.add(news);
        } else {
          otherNewsList.add(news);
        }
      }
    }

    // List of members that followed members' following members
    List<Member> followedFollowing = [];
    if (jsonResponse['data']['followedFollowing'].isNotEmpty) {
      for (var member in jsonResponse['data']['followedFollowing']) {
        followedFollowing.add(Member.fromJson(member));
      }
    }

    // List of members that followed same publishers or categories
    // Now take up to 20 members
    List<Member> otherRecommendMembers = [];
    if (jsonResponse['data']['otherRecommendMembers'].isNotEmpty) {
      for (var member in jsonResponse['data']['otherRecommendMembers']) {
        otherRecommendMembers.add(Member.fromJson(member));
      }
      // sort by amount of comments and picks in last 24 hours
      otherRecommendMembers.sort((a, b) {
        int num = b.commentCount!.compareTo(a.commentCount!);
        if (num != 0) return num;
        return b.pickCount!.compareTo(a.pickCount!);
      });
    }

    Map<String, dynamic> result = {
      'followingNewsList': followingNewsList,
      'latestCommentsNewsList': latestCommentsNewsList,
      'otherNewsList': otherNewsList,
      'followedFollowing': followedFollowing,
      'otherRecommendMembers': otherRecommendMembers,
      'followingMemberIds': followingMemberIds,
      'followingCategorySlugs': followingCategorySlugs,
      'followingPublisherIds': followingPublisherIds,
      'myId': myId,
    };

    return result;
  }

  Future<NewsListItemList> fetchNewsList() async {
    const String query = """
    query(
        \$storyWhere: StoryWhereInput!
      ){
        stories(
          where: \$storyWhere
          orderBy: [{published_date: desc}]
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
        }
        storiesCount
      }
    """;

    Map<String, dynamic> variables = {
      "storyWhere": {
        "published_date": {
          "gte": DateTime.now()
              .subtract(const Duration(hours: 24))
              .toUtc()
              .toIso8601String()
        }
      }
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    String key = 'fetchNewsList';
    jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      api,
      jsonEncode(graphqlBody.toJson()),
      maxAge: newsTabStoryList,
      headers: {"Content-Type": "application/json"},
    );

    NewsListItemList newsList = NewsListItemList();
    if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
      newsList = NewsListItemList.fromJson(jsonResponse['data']['stories']);
      newsList.allStoryCount = jsonResponse['data']['storiesCount'];
    }

    return newsList;
  }
}
