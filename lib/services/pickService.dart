import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/graphqlBody.dart';

class PickService {
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

  Future<String?> createPick({
    required String memberId,
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
          "connect": {"id": memberId}
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
    required String memberId,
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
            email
          }
          content
          state
          published_date
        }
      }
    }
    """;

    Map<String, Map> variables = {
      "data": {
        "member": {
          "connect": {"id": memberId}
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
              "connect": {"id": memberId}
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
              "connect": {"id": memberId}
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
}
