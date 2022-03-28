import 'dart:convert';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/graphqlBody.dart';

class PickService {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String api = Environment().config.readrMeshApi;

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
      "email": Environment().config.appHelperEmail,
      "password": Environment().config.appHelperPassword,
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

  Future<String?> createPick({
    required String targetId,
    required PickObjective objective,
    required PickState state,
    required PickKind kind,
    bool paywall = false,
    String? rootCommentId,
  }) async {
    String mutation = """
    mutation(
      \$data: PickCreateInput!
    ){
      createPick(
        data: \$data
      ){
        id
      }
    }
    """;

    Map<String, Map> variables = {
      "data": {
        "member": {
          "connect": {"id": UserHelper.instance.currentUser.memberId}
        },
        "objective": objective.toString().split('.').last,
        "kind": kind.toString().split('.').last,
        "state": state.toString().split('.').last,
        "picked_date": DateTime.now().toUtc().toIso8601String(),
        "paywall": paywall,
        "is_active": true
      }
    };

    Map<String, Map> additionalVariables;
    if (objective == PickObjective.story) {
      additionalVariables = {
        "story": {
          "connect": {"id": targetId}
        }
      };
    } else if (objective == PickObjective.collection) {
      additionalVariables = {
        "collection": {
          "connect": {"id": targetId}
        }
      };
    } else {
      additionalVariables = {
        "comment": {
          "connect": {"id": targetId}
        }
      };
    }

    variables['data']!.addAll(additionalVariables);

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

      return jsonResponse['data']['createPick']['id'];
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPickAndComment({
    required String targetId,
    required PickObjective objective,
    required PickState state,
    required PickKind kind,
    required String commentContent,
    bool paywall = false,
    String? rootCommentId,
  }) async {
    String mutation = """
    mutation(
      \$data: PickCreateInput!
    ){
      createPick(
        data: \$data
      ){
        id
        pick_comment{
          id
          member{
            id
            nickname
            customId
            avatar
          }
          content
          state
          published_date
          is_edited
        }
      }
    }
    """;

    Map<String, Map> variables = {
      "data": {
        "member": {
          "connect": {"id": UserHelper.instance.currentUser.memberId}
        },
        "objective": objective.toString().split('.').last,
        "kind": kind.toString().split('.').last,
        "state": state.toString().split('.').last,
        "picked_date": DateTime.now().toUtc().toIso8601String(),
        "paywall": paywall,
        "is_active": true
      }
    };

    if (objective == PickObjective.story) {
      variables['data']!.addAll({
        "story": {
          "connect": {"id": targetId}
        }
      });
    } else if (objective == PickObjective.collection) {
      variables['data']!.addAll({
        "collection": {
          "connect": {"id": targetId}
        }
      });
    } else {
      variables['data']!.addAll({
        "comment": {
          "connect": {"id": targetId}
        }
      });
    }

    if (objective == PickObjective.story) {
      variables['data']!.addAll({
        "pick_comment": {
          "create": {
            "member": {
              "connect": {"id": UserHelper.instance.currentUser.memberId}
            },
            "story": {
              "connect": {"id": targetId}
            },
            "content": commentContent,
            "state": state.toString().split('.').last,
            "published_date": DateTime.now().toUtc().toIso8601String()
          }
        }
      });
    } else if (objective == PickObjective.comment) {
      variables['data']!.addAll({
        "pick_comment": {
          "create": {
            "member": {
              "connect": {"id": UserHelper.instance.currentUser.memberId}
            },
            "parent": {
              "connect": {"id": targetId}
            },
            "content": commentContent,
            "state": state.toString().split('.').last,
            "published_date": DateTime.now().toUtc().toIso8601String()
          }
        }
      });
      if (rootCommentId != null) {
        variables['data']!['pick_comment']!['create']!.addAll({
          "root": {
            "connect": {"id": rootCommentId}
          }
        });
      }
    } else {
      return null;
    }

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

      Map<String, dynamic> result = {
        'pickId': jsonResponse['data']['createPick']['id'],
        'pickComment': Comment.fromJson(
            jsonResponse['data']['createPick']['pick_comment'][0])
      };

      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePick(String pickId) async {
    String mutation = """
      mutation(
        \$pickId: ID
      ){
        updatePick(
          where:{
            id: \$pickId
          }
          data:{
            is_active: false
          }
        ){
          id
        }
      }
      """;

    Map<String, String> variables = {"pickId": pickId};

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

  Future<bool> deletePickAndComment(String pickId, String commentId) async {
    String mutation = """
      mutation(
        \$pickId: ID
        \$pickCommentId: ID
      ){
        updatePick(
          where:{
            id: \$pickId
          }
          data:{
            is_active: false
          }
        ){
          id
        }
        updateComment(
          where:{
            id: \$pickCommentId
          }
          data:{
            is_active: false
          }
        ){
          id
        }
      }
      """;

    Map<String, String> variables = {
      "pickId": pickId,
      "pickCommentId": commentId
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

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }
}
