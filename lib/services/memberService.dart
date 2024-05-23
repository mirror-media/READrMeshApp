import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
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

  Future<void> addBlockMember(String blockMemberId);

  Future<void> removeBlockMember(String blockMemberId);

  Future<List<Member>> fetchBlockMembers(List<String> blockMemberIds);
}

class MemberService implements MemberRepos {
  final ProxyServerService proxyServerService = Get.find();

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
        pickCount(
          where:{
            is_active:{
              equals: true
            }
            kind:{
              notIn:["bookmark"]
            }
          }
        )
        bookmarkCount: pickCount(
          where:{
            is_active:{
              equals: true
            }
            kind:{
              equals:"bookmark"
            }
          }
        )
        commentCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
        block(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
        }
        blocked(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "firebaseId": FirebaseAuth.instance.currentUser!.uid,
    };
    final ProxyServerService proxyServerService = Get.find();
    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    // final test =await proxyServerService.test();
    // final jsonResponse2 =
    //     await proxyServerService.gql(query: query, variables: variables);

    // create new member when firebase is signed in but member is not created
    if (jsonResponse.data!['members'].isEmpty) {
      return null;
    } else {
      return Member.fromJson(jsonResponse.data!['members'][0]);
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

    final jsonResponse = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
      throwException: false,
    );

    if (!jsonResponse.hasException) {
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
    } else if (jsonResponse.exception?.graphqlErrors
            .any((element) => element.message.contains('customId')) ??
        false) {
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

    try {
      await Get.find<GraphQLService>().mutation(
        mutationBody: mutation,
        variables: variables,
      );

      return true;
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

    try {
      final jsonResponse = await Get.find<GraphQLService>().mutation(
        mutationBody: mutation,
        variables: variables,
      );

      List<Publisher> followPublisher = [];
      for (var publisher in jsonResponse.data!['updateMember']
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

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
      throwException: false,
    );

    return !result.hasException;
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
      contentType: MediaType('image', 'jpg'),
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

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<PickIdItem> pickIdList = [];
    for (var item in jsonResponse.data!['member']['storyPicks']) {
      pickIdList
          .add(PickIdItem.fromJson(item, PickObjective.story, PickKind.read));
    }

    for (var item in jsonResponse.data!['member']['collectionPicks']) {
      pickIdList.add(
          PickIdItem.fromJson(item, PickObjective.collection, PickKind.read));
    }

    for (var item in jsonResponse.data!['member']['bookmarks']) {
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
        avatar_image{
          id
          resized{
            original
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "memberId": id,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    if (jsonResponse.data!['member'] != null &&
        jsonResponse.data!['member']['is_active']) {
      return Member.fromJson(jsonResponse.data!['member']);
    } else {
      return null;
    }
  }

  @override
  Future<void> addBlockMember(String blockMemberId) async {
    const String mutation = """
mutation(
  \$blockId: ID
  \$myId: ID
){
  updateMember(
    where:{
      id: \$myId
    }
    data:{
      block:{
        connect:{
          id: \$blockId
        }
      }
      following:{
        disconnect:{
          id: \$blockId
        }
      }
      follower:{
        disconnect:{
          id: \$blockId
        }
      }
    }
  ){
    block(
      where:{
        is_active:{
          equals: true
        }
      }
    ){
      id
    }
  }
}
    """;

    Map<String, dynamic> variables = {
      "blockId": blockMemberId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> removeBlockMember(String blockMemberId) async {
    const String mutation = """
mutation(
  \$blockId: ID
  \$myId: ID
){
  updateMember(
    where:{
      id: \$myId
    }
    data:{
      block:{
        disconnect:{
          id: \$blockId
        }
      }
    }
  ){
    block(
      where:{
        is_active:{
          equals: true
        }
      }
    ){
      id
    }
  }
}
    """;

    Map<String, dynamic> variables = {
      "blockId": blockMemberId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<List<Member>> fetchBlockMembers(List<String> blockMemberIds) async {
    const String query = """
query(
  \$blockIds: [ID!]
){
  members(
    where:{
      is_active:{
        equals: true
      }
      id:{
        in: \$blockIds
      }
    }
    orderBy:{
      customId: asc
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
    customId
  }
}
    """;

    Map<String, dynamic> variables = {
      "blockIds": blockMemberIds,
    };

    final response =
        await proxyServerService.gql(query: query, variables: variables);

    return List<Member>.from(
        response.data!['members'].map((element) => Member.fromJson(element)));
  }
}
