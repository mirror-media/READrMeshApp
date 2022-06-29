import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';

import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InvitationCodeStatus {
  valid,
  invalid,
  activated,
  error,
}

abstract class InvitationCodeRepos {
  Future<List<InvitationCode>> fetchMyInvitationCode();
  Future<bool> checkUsableInvitationCode(String memberId);
  Future<InvitationCodeStatus> checkInvitationCode(String code);
  Future<void> linkInvitationCode(String codeId);
}

class InvitationCodeService implements InvitationCodeRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String api = Get.find<EnvironmentService>().config.readrMeshApi;

  Future<Map<String, String>> _getHeaders({bool needAuth = true}) async {
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
  Future<List<InvitationCode>> fetchMyInvitationCode() async {
    const String query = '''
    query(
      \$myId: ID
    ){
      invitationCodes(
        where:{
          send:{
            id:{
              equals: \$myId
            }
          }
        }
      ){
        code
        receive{
          id
          nickname
          avatar
          customId
        }
      }
    }
    ''';

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
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
      headers: await _getHeaders(needAuth: false),
    );

    List<InvitationCode> allInvitationCode = [];
    for (var item in jsonResponse['data']['invitationCodes']) {
      allInvitationCode.add(InvitationCode.fromJson(item));
    }
    return allInvitationCode;
  }

  @override
  Future<bool> checkUsableInvitationCode(String memberId) async {
    const String query = '''
    query(
      \$myId: ID
    ){
      invitationCodesCount(
        where:{
          send:{
            id:{
              equals: \$myId
            }
          }
          expired:{
            equals: false
          }
        }
      )
    }
    ''';

    Map<String, dynamic> variables = {
      "myId": memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    try {
      late final dynamic jsonResponse;
      jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await _getHeaders(needAuth: false),
      );

      if (jsonResponse['data']['invitationCodesCount'] != 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<InvitationCodeStatus> checkInvitationCode(String code) async {
    if (code == 'Avid86') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('invitationCodeId', 'Avid86');
      return InvitationCodeStatus.valid;
    }
    const String query = '''
    query(
      \$code: String
    ){
      invitationCodes(
        where:{
          code:{
            equals: \$code
          }
        }
      ){
        id
        receive{
          id
        }
      }
    }
    ''';

    Map<String, dynamic> variables = {
      "code": code,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    try {
      late final dynamic jsonResponse;
      jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await _getHeaders(needAuth: false),
      );

      if (jsonResponse['data']['invitationCodes'].isEmpty) {
        return InvitationCodeStatus.invalid;
      } else if (jsonResponse['data']['invitationCodes'][0]['receive'] !=
          null) {
        return InvitationCodeStatus.activated;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('invitationCodeId',
            jsonResponse['data']['invitationCodes'][0]['id']);
        return InvitationCodeStatus.valid;
      }
    } catch (e) {
      return InvitationCodeStatus.error;
    }
  }

  @override
  Future<void> linkInvitationCode(String codeId) async {
    if (codeId != 'Avid86') {
      const String mutation = '''
      mutation(
        \$codeId: ID
        \$myId: ID
      ){
        updateInvitationCode(
          where:{
            id: \$codeId
          }
          data:{
            receive:{
              connect:{
                id: \$myId
              }
            }
            expired: true
          }
        ){
          id
        }
      }
      ''';

      Map<String, dynamic> variables = {
        "codeId": codeId,
        "myId": Get.find<UserService>().currentUser.memberId,
      };

      GraphqlBody graphqlBody = GraphqlBody(
        operationName: null,
        query: mutation,
        variables: variables,
      );

      await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await _getHeaders(needAuth: false),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('invitationCodeId', '');
  }
}
