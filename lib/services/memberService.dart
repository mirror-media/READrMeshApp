import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';

class MemberService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    // TODO: Change back to firebase token when verify firebase token is finished
    String token = await _fetchCMSUserToken();
    //String token = await FirebaseAuth.instance.currentUser!.getIdToken();
    headers.addAll({"Authorization": "Bearer $token"});

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

  Future<Member?> fetchMemberData(User firebaseUser) async {
    String query = """
    query fetchMemberData(
	    \$firebaseId: String
    ){
	    members(
        where: {
          firebaseId: {
            equals: \$firebaseId
          }
        }
      ){
        id
		    nickname
		    firebaseId
		    email
        name
	    }
    }
    """;

    Map<String, String> variables = {"firebaseId": firebaseUser.uid};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await getHeaders(),
    );

    // create new member when firebase is signed in but member is not created
    if (jsonResponse['data']['members'].isEmpty) {
      Member? newMember = await createMember(firebaseUser);
      return newMember;
    } else {
      return Member.fromJson(jsonResponse['data']['members'][0]);
    }
  }

  Future<Member?> createMember(User firebaseUser) async {
    String mutation = """
    mutation (
	    \$email: String
	    \$firebaseId: String
  		\$name: String
  		\$nickname: String
    ){
	    createMember(
		    data: { 
			    email: \$email,
			    firebaseId: \$firebaseId,
          name: \$name,
          nickname: \$nickname,
          is_active: true
		    }) {
        id
		    nickname
        name
		    firebaseId
		    email
      }
    }
    """;

    // if facebook authUser has no email,then feed email field with prompt
    String feededEmail =
        firebaseUser.email ?? '[0x0001] - firebaseId:${firebaseUser.uid}';

    String nickname;
    if (firebaseUser.displayName != null) {
      nickname = firebaseUser.displayName!;
    } else if (firebaseUser.email != null) {
      nickname = firebaseUser.email!.split('@')[0];
    } else {
      var splitUid = firebaseUser.uid.split('');
      String randomName = '';
      for (int i = 0; i < 5; i++) {
        randomName = randomName + splitUid[i];
      }
      nickname = 'User $randomName';
    }

    Map<String, String> variables = {
      "email": feededEmail,
      "firebaseId": firebaseUser.uid,
      "name": nickname,
      "nickname": nickname
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

      return Member.fromJson(jsonResponse['data']['createMember']);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteMember(String memberId, String token) async {
    String mutation = """
    mutation(
      \$id: ID
    ){
      updateMember(
        where:{
          id: \$id
        }
        data:{
          is_active: false
        }
      ){
        is_active
      }
    }
    """;
    Map<String, String> variables = {"id": memberId};

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

  Future<bool> addFollowingMember(
      String memberId, String targetMemberId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$targetMemberId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          following:{
            connect:{
              id: \$targetMemberId
            } 
          }
        }
      ){
        following{
          id
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": memberId,
      "targetMemberId": targetMemberId
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

  Future<bool> removeFollowingMember(
      String memberId, String targetMemberId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$targetMemberId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          following:{
            disconnect:{
              id: \$targetMemberId
            } 
          }
        }
      ){
        following{
          id
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": memberId,
      "targetMemberId": targetMemberId
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

  Future<String?> addPick({
    required String memberId,
    required String targetId,
    required PickObjective objective,
    required PickState state,
    required PickKind kind,
    bool hasComment = false,
    String? commentContent,
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
        "paywall": paywall
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

    if (hasComment && commentContent != null) {
      if (objective == PickObjective.story) {
        additionalVariables.addAll({
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
        additionalVariables.addAll({
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
          additionalVariables['pick_comment']!['create']!.addAll({
            "root": {
              "connect": {"id": rootCommentId}
            }
          });
        }
      } else {
        return null;
      }
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

  Future<bool> deletePick(String pickId) async {
    String mutation = """
      mutation(
        \$pickId: ID
      ){
        deletePick(
          where:{
            id: \$pickId
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
