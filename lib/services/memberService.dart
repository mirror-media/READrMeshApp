import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pickIdItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MemberRepos {
  Future<Member?> fetchMemberData();
  Future<Member?> createMember(String nickname, {int? tryTimes});
  Future<bool> deleteMember(String memberId);
  Future<List<Publisher>?> addFollowPublisher(String publisherId);
  Future<bool> updateMember({
    required String memberId,
    required String nickname,
    required String customId,
    String? intro,
  });
  Future<bool> updateMemberAndAvatar({
    required String memberId,
    required String nickname,
    required String customId,
    String? intro,
    required String imagePath,
  });
  Future<bool> deleteAvatarPhoto(String imageId);
  Future<bool> deleteAvatarUrl(String memberId);
  Future<List<PickIdItem>> fetchAllPicksAndBookmarks();
  Future<Member?> fetchMemberDataById(String id);
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
        avatar_image{
          id
          resized{
            original
          }
        }
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
          avatar_image{
            resized{
              original
            }
          }
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
  Future<bool> deleteMember(String memberId) async {
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
        headers: await _getHeaders(),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
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
  Future<bool> updateMember({
    required String memberId,
    required String nickname,
    required String customId,
    String? intro,
  }) async {
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
      "id": memberId,
      "nickname": nickname,
      "customId": customId,
      "intro": intro ?? '',
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

    return !jsonResponse.containsKey('errors');
  }

  @override
  Future<bool> updateMemberAndAvatar({
    required String memberId,
    required String nickname,
    required String customId,
    String? intro,
    required String imagePath,
  }) async {
    String mutation = """
mutation(
  \$image: Upload
  \$memberId: ID
  \$nickname: String
  \$customId: String
  \$intro: String
  \$imageName: String
){
  updateMember(
    where:{
      id: \$memberId
    }
    data:{
      nickname: \$nickname
      customId: \$customId
      intro: \$intro
      avatar: ""
      avatar_image:{
        create:{
          name: \$imageName
          file:{
            upload: \$image
          }
        }
      }
    }
  ){
    id
  }
}
    """;

    var multipartFile = await http.MultipartFile.fromPath(
      '',
      imagePath,
      contentType:
          MediaType("image", p.extension(imagePath).replaceFirst('.', '')),
    );

    Map<String, dynamic> variables = {
      "memberId": memberId,
      "image": multipartFile,
      "nickname": nickname,
      "customId": customId,
      "intro": intro ?? '',
      "imageName": 'Member${memberId}_avatar',
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    return !result.hasException;
  }

  @override
  Future<bool> deleteAvatarPhoto(String imageId) async {
    String mutation = """
mutation(
  \$imageId: ID
){
  deletePhoto(
    where:{
      id: \$imageId
    }
  ){
    id
  }
}
    """;
    Map<String, dynamic> variables = {
      "imageId": imageId,
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    return !result.hasException;
  }

  @override
  Future<bool> deleteAvatarUrl(String memberId) async {
    String mutation = """
mutation(
  \$memberId: ID
){
  updateMember(
    where:{
      id: \$memberId
    }
    data:{
      avatar: ""
    }
  ){
    id
  }
}
    """;
    Map<String, dynamic> variables = {
      "memberId": memberId,
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    return !result.hasException;
  }

  @override
  Future<List<PickIdItem>> fetchAllPicksAndBookmarks() async {
    const String query = """
query(
  \$memberId: ID
){
  member(
    where:{
      id: \$memberId
    }
  ){
    storyPicks: pick(
      where:{
        kind:{
          equals: "read"
        }
        is_active:{
          equals: true
        }
        story:{
          is_active:{
            equals: true
          }
        }
      }
    ){
      pick_comment{
        id
      }
      story{
        id
      }
    }
    collectionPicks: pick(
      where:{
        kind:{
          equals: "read"
        }
        is_active:{
          equals: true
        }
        collection:{
          status:{
            equals: "publish"
          }
        }
      }
    ){
      pick_comment{
        id
      }
      collection{
        id
      }
    }
    bookmarks: pick(
      where:{
        kind:{
          equals: "bookmark"
        }
        is_active:{
          equals: true
        }
        story:{
          is_active:{
            equals: true
          }
        }
      }
    ){
      story{
        id
      }
    }
  }
}
    """;

    Map<String, String> variables = {
      "memberId": Get.find<UserService>().currentUser.memberId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await _getHeaders(),
    );

    List<PickIdItem> pickIdList = [];
    for (var item in jsonResponse['data']['member']['storyPicks']) {
      pickIdList
          .add(PickIdItem.fromJson(item, PickObjective.story, PickKind.read));
    }

    for (var item in jsonResponse['data']['member']['collectionPicks']) {
      pickIdList.add(
          PickIdItem.fromJson(item, PickObjective.collection, PickKind.read));
    }

    for (var item in jsonResponse['data']['member']['bookmarks']) {
      pickIdList.add(
          PickIdItem.fromJson(item, PickObjective.story, PickKind.bookmark));
    }

    return pickIdList;
  }

  @override
  Future<Member?> fetchMemberDataById(String id) async {
    const String query = """
        query(
      \$memberId: ID
    ){
      member(
        where:{
          id: \$memberId
        }
      ){
        id
        nickname
        email
        avatar
        customId
        is_active
      }
    }
    """;

    Map<String, dynamic> variables = {
      "memberId": id,
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

    if (jsonResponse['data']['member'] != null &&
        jsonResponse['data']['member']['is_active']) {
      return Member.fromJson(jsonResponse['data']['member']);
    } else {
      return null;
    }
  }
}
