import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberService {
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
      headers: await getHeaders(needAuth: false),
    );

    // create new member when firebase is signed in but member is not created
    if (jsonResponse['data']['members'].isEmpty) {
      return null;
    } else {
      return Member.fromJson(jsonResponse['data']['members'][0]);
    }
  }

  Future<Member?> createMember({int? tryTimes}) async {
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
      "name": nickname,
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
      headers: await getHeaders(),
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
      await UserHelper.instance.fetchUserData();
      return UserHelper.instance.currentUser;
    } else if (jsonResponse['errors'][0]['message'].contains('customId')) {
      int times = 2;
      if (tryTimes != null) {
        times = tryTimes++;
      }
      return await createMember(tryTimes: times);
    } else {
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
      "memberId": UserHelper.instance.currentUser.memberId,
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
      "memberId": UserHelper.instance.currentUser.memberId,
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
      "memberId": UserHelper.instance.currentUser.memberId,
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
        headers: await getHeaders(),
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
      "memberId": UserHelper.instance.currentUser.memberId,
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
        headers: await getHeaders(),
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
        headers: await getHeaders(),
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
