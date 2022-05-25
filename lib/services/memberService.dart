import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';

import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MemberRepos {
  Future<Member?> fetchMemberData();
  Future<Member?> createMember(String nickname, {int? tryTimes});
  Future<bool> deleteMember();
  Future<List<Member>?> addFollowingMember(String targetMemberId);
  Future<List<Member>?> removeFollowingMember(String targetMemberId);
  Future<List<Publisher>?> addFollowPublisher(String publisherId);
  Future<List<Publisher>?> removeFollowPublisher(String publisherId);
  Future<bool?> updateMember(Member member);
}

class MemberService implements MemberRepos {
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
  Future<Member?> fetchMemberData() async {
    const String query = """
    query(
      \$firebaseId: String
    ){
      members(
        where:{
          firebaseId: {
            equals: \$firebaseId
          }
          is_active:{
            equals: true
          }
        }
      ){
        id
        nickname
        firebaseId
        email
        avatar
        verified
        customId
        intro
        following(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
          nickname
          avatar
        }
        following_category{
          id
          slug
          title
        }
        follow_publisher{
          id
          title
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
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(needAuth: false),
    );

    // create new member when firebase is signed in but member is not created
    if (jsonResponse['data']['members'].isEmpty) {
      return null;
    } else {
      return Member.fromJson(jsonResponse['data']['members'][0]);
    }
  }

  @override
  Future<Member?> createMember(String nickname, {int? tryTimes}) async {
    String mutation = """
    mutation (
	    \$email: String
	    \$firebaseId: String
  		\$name: String
  		\$nickname: String
  		\$avatar: String
      \$customId: String
    ){
	    createMember(
		    data: { 
			    email: \$email,
			    firebaseId: \$firebaseId,
          name: \$name,
          nickname: \$nickname,
          is_active: true,
          avatar: \$avatar,
          customId: \$customId
		    }) {
        id
        nickname
        firebaseId
        email
        avatar
        verified
        customId
        intro
        following(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
          nickname
        }
        following_category{
          id
          slug
          title
        }
        follow_publisher{
          id
          title
        }
      }
    }
    """;

    User firebaseUser = FirebaseAuth.instance.currentUser!;

    // if facebook authUser has no email,then feed email field with prompt
    String feededEmail =
        firebaseUser.email ?? '[0x0001] - firebaseId:${firebaseUser.uid}';

    String customId = '';
    if (firebaseUser.email != null) {
      customId = firebaseUser.email!.split('@')[0];
    } else {
      var splitUid = firebaseUser.uid.split('');
      for (int i = 0; i < 5; i++) {
        customId = customId + splitUid[i];
      }
    }

    if (tryTimes != null) {
      customId = customId + tryTimes.toString();
    }

    Map<String, String> variables = {
      "email": feededEmail,
      "firebaseId": firebaseUser.uid,
      "name": FirebaseAuth.instance.currentUser?.displayName ?? nickname,
      "nickname": nickname,
      "avatar": firebaseUser.photoURL ?? "",
      "customId": customId
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    if (!jsonResponse.containsKey('errors')) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> followingPublisherIds =
          prefs.getStringList('followingPublisherIds') ?? [];
      if (followingPublisherIds.isNotEmpty) {
        List<Future> futureList = [];
        for (var publisherId in followingPublisherIds) {
          futureList.add(addFollowPublisher(publisherId));
        }
        await Future.wait(futureList);
      }
      await Get.find<UserService>().fetchUserData();
      return Get.find<UserService>().currentUser;
    } else if (jsonResponse['errors'][0]['message'].contains('customId')) {
      int times;
      if (tryTimes != null) {
        times = tryTimes + 1;
      } else {
        times = 2;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      return await createMember(nickname, tryTimes: times);
    } else {
      return null;
    }
  }

  @override
  Future<bool> deleteMember() async {
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
    Map<String, String> variables = {
      "id": Get.find<UserService>().currentUser.memberId
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
        headers: await _getHeaders(),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Member>?> addFollowingMember(String targetMemberId) async {
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
          nickname
          avatar
          customId
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": Get.find<UserService>().currentUser.memberId,
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
        headers: await _getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Member> followingMembers = [];
      for (var member in jsonResponse['data']['updateMember']['following']) {
        followingMembers.add(Member.fromJson(member));
      }

      return followingMembers;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Member>?> removeFollowingMember(String targetMemberId) async {
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
          nickname
          avatar
          customId
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": Get.find<UserService>().currentUser.memberId,
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
        headers: await _getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Member> followingMembers = [];
      for (var member in jsonResponse['data']['updateMember']['following']) {
        followingMembers.add(Member.fromJson(member));
      }

      return followingMembers;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Publisher>?> addFollowPublisher(String publisherId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$publisherId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          follow_publisher:{
            connect:{
              id: \$publisherId
            }
          }
        }
      ){
        follow_publisher{
          id
          title
          logo
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": Get.find<UserService>().currentUser.memberId,
      "publisherId": publisherId
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
        headers: await _getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Publisher> followPublisher = [];
      for (var publisher in jsonResponse['data']['updateMember']
          ['follow_publisher']) {
        followPublisher.add(Publisher.fromJson(publisher));
      }

      return followPublisher;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Publisher>?> removeFollowPublisher(String publisherId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$publisherId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          follow_publisher:{
            disconnect:{
              id: \$publisherId
            }
          }
        }
      ){
        follow_publisher{
          id
          title
          logo
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": Get.find<UserService>().currentUser.memberId,
      "publisherId": publisherId
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
        headers: await _getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Publisher> followPublisher = [];
      for (var publisher in jsonResponse['data']['updateMember']
          ['follow_publisher']) {
        followPublisher.add(Publisher.fromJson(publisher));
      }

      return followPublisher;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool?> updateMember(Member member) async {
    String mutation = """
    mutation(
      \$id: ID
      \$nickname: String
      \$customId: String
      \$intro: String
    ){
      updateMember(
        where:{
          id: \$id
        }
        data:{
          nickname: \$nickname
          customId: \$customId
          intro: \$intro
        }
      ){
        id
      }
    }
    """;
    Map<String, String> variables = {
      "id": member.memberId,
      "nickname": member.nickname,
      "customId": member.customId,
      "intro": member.intro ?? '',
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
        headers: await _getHeaders(),
      );

      // true mean success, false mean customId error, null mean other error.
      if (!jsonResponse.containsKey('errors')) {
        return true;
      } else if (jsonResponse['errors'][0]['message'].contains('customId')) {
        return false;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
