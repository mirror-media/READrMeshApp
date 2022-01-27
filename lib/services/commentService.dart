import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/graphqlBody.dart';

class CommentService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  Future<Map<String, String>> getHeaders({bool needAuth = true}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (needAuth) {
      // TODO: Change back to firebase token when verify firebase token is finished
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

  Future<List<Comment>?> createComment({
    required String memberId,
    required String storyId,
    required String content,
    required CommentTransparency state,
  }) async {
    String mutation = """
      mutation(
        \$myId: ID
        \$storyId: ID
        \$content: String
        \$published_date: DateTime
        \$state: String
      ){
        createComment(
          data:{
            member:{
              connect:{
                id: \$myId
              }
            }
            story:{
              connect:{
                id: \$storyId
              }
            }
            content: \$content
            published_date: \$published_date
            is_active: true
            state: \$state
          }
        ){
          story{
            comment(
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
            ){
              id
              member{
                id
                nickname
                email
                avatar
              }
              content
              state
              published_date
              likeCount
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
      "myId": memberId,
      "storyId": storyId,
      "content": content,
      "published_date": DateTime.now().toUtc().toIso8601String(),
      "state": state.toString().split('.').last,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );
      if (jsonResponse.containsKey('errors')) {
        return null;
      }

      List<Comment> allComments = [];
      for (var item in jsonResponse['data']['createComment']['story']
          ['comment']) {
        allComments.add(Comment.fromJson(item));
      }

      return allComments;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    String mutation = """
      mutation(
        \$commentId: ID
      ){
        updateComment(
          where:{
            id: \$commentId
          }
          data:{
            is_active: false
          }
        ){
          id
        }
      }
      """;

    Map<String, String> variables = {"commentId": commentId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }

  Future<List<Comment>?> fetchCommentsByStoryId(
      String storyId, String memberId) async {
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
          }
        ){
          id
          member{
            id
            nickname
            email
            avatar
          }
          content
          state
          published_date
          likeCount
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
      "myId": memberId,
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
        headers: await getHeaders(needAuth: false),
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

  Future<int?> addLike({
    required String memberId,
    required String commentId,
  }) async {
    String mutation = """
    mutation(
      \$commentId: ID
      \$memberId: ID
    ){
      updateComment(
        where:{
          id: \$commentId
        }
        data:{
          like:{
            connect:{
              id: \$memberId
            }
          }
        }
      ){
        likeCount
      }
    }
    """;

    Map<String, dynamic> variables = {
      "commentId": commentId,
      "memberId": memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );
      if (jsonResponse.containsKey('errors')) {
        return null;
      }

      return jsonResponse['data']['updateComment']['likeCount'];
    } catch (e) {
      return null;
    }
  }

  Future<int?> removeLike({
    required String memberId,
    required String commentId,
  }) async {
    String mutation = """
    mutation(
      \$commentId: ID
      \$memberId: ID
    ){
      updateComment(
        where:{
          id: \$commentId
        }
        data:{
          like:{
            disconnect:{
              id: \$memberId
            }
          }
        }
      ){
        likeCount
      }
    }
    """;

    Map<String, dynamic> variables = {
      "commentId": commentId,
      "memberId": memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );
      if (jsonResponse.containsKey('errors')) {
        return null;
      }

      return jsonResponse['data']['updateComment']['likeCount'];
    } catch (e) {
      return null;
    }
  }
}
