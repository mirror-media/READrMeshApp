import 'dart:convert';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class CommentRepos {
  Future<List<Comment>?> fetchCommentsByStoryId(String storyId);
  Future<List<Comment>> fetchCommentsByCollectionId(String collectionId);
}

class CommentService implements CommentRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String api = Get.find<EnvironmentService>().config.readrMeshApi;

  Future<Map<String, String>> _getHeaders({bool needAuth = true}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (needAuth) {
      String token = await _fetchCMSUserToken();
      //String token = await FirebaseAuth.instance.currentUser!.getIdToken();
      headers.addAll({"Authorization": "Bearer $token"});
    }

    return headers;
  }

  // Get READr CMS User token for authorization
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
      "email": Get.find<EnvironmentService>().config.appHelperEmail,
      "password": Get.find<EnvironmentService>().config.appHelperPassword,
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

  @override
  Future<List<Comment>?> fetchCommentsByStoryId(String storyId) async {
    String query = """
      query(
        \$storyId: ID
        \$myId: ID
      ){
        comments(
          orderBy:{
            published_date: desc
          }
          where:{
            story:{
              id:{
                equals: \$storyId
              }
            }
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
      """;

    Map<String, String> variables = {
      "storyId": storyId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await _getHeaders(needAuth: false),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }

      List<Comment> allComments = [];
      for (var item in jsonResponse['data']['comments']) {
        allComments.add(Comment.fromJson(item));
      }

      return allComments;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Comment>> fetchCommentsByCollectionId(String collectionId) async {
    String query = """
      query(
        \$collectionId: ID
        \$myId: ID
      ){
        comments(
          orderBy:{
            published_date: desc
          }
          where:{
            collection:{
              id:{
                equals: \$collectionId
              }
            }
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
      """;

    Map<String, String> variables = {
      "collectionId": collectionId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(needAuth: false),
    );

    List<Comment> allComments = [];
    for (var item in jsonResponse['data']['comments']) {
      allComments.add(Comment.fromJson(item));
    }

    return allComments;
  }
}
