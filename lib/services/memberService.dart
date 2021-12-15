import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';

class MemberService {
  final ApiBaseHelper _helper = ApiBaseHelper();

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
		    token
	    }
    }
    """;

    Map<String, String> variables = {
      "email": DevConfig().memberManagerEmail,
      "password": DevConfig().memberManagerPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['token'];

    return token;
  }

  Future<Member> fetchMemberData(User firebaseUser) async {
    String query = """
    query fetchMemberData(
	    \$firebaseId: String!
    ){
	    allMembers(where: {firebaseId: \$firebaseId}){
        id
		    nickName
		    firebaseId
		    email
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
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: getHeaders(token),
    );

    return Member.fromJson(jsonResponse['data']['allMembers'][0]);
  }

  Future<Member?> createMember(User firebaseUser) async {
    String mutation = """
    mutation (
	    \$email: String
	    \$firebaseId: String!
    ){
	    createMember(
		    data: { 
			    email: \$email,
			    firebaseId: \$firebaseId,
			    state: active
		    }) {
        id
		    nickName
		    firebaseId
		    email
      }
    }
    """;

    // if facebook authUser has no email,then feed email field with prompt
    String feededEmail =
        firebaseUser.email ?? '[0x0001] - firebaseId:${firebaseUser.uid}';

    Map<String, String> variables = {
      "email": feededEmail,
      "firebaseId": firebaseUser.uid,
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
        Environment().config.graphqlApi,
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
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        headers: getHeaders(cmsToken),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }
}
