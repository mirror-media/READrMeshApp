import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
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

  Future<Comment?> createComment({
    required String memberId,
    required String storyId,
    required String content,
  }) async {
    String mutation = """
    mutation(
      \$myId: ID
      \$storyId: ID
      \$content: String
      \$published_date: DateTime
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
    }
    """;

    Map<String, dynamic> variables = {
      "myId": memberId,
      "storyId": storyId,
      "content": content,
      "published_date": DateTime.now().toUtc().toIso8601String()
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

      return Comment.fromJson(jsonResponse['data']['createComment']);
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
}
