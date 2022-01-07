import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';

class MemberService {
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

    // TODO: Change back to firebase token when verify firebase token is finished
    String token = await _fetchCMSUserToken();
    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: getHeaders(token),
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
          nickname: \$nickname
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
      // TODO: Change back to firebase token when verify firebase token is finished
      String token = await _fetchCMSUserToken();
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: getHeaders(token),
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
    mutation (\$id: ID!) {
      updateMember(id: \$id, data: { state: inactive }) {
        state
      }
    }
    """;
    Map<String, String> variables = {"id": memberId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );
    // TODO: Delete when verify firebase token is finished
    String cmsToken = await _fetchCMSUserToken();

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: getHeaders(cmsToken),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }
}
