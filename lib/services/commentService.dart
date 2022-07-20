import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/comment.dart';

abstract class CommentRepos {
  Future<List<Comment>?> fetchCommentsByStoryId(String storyId);
  Future<List<Comment>> fetchCommentsByCollectionId(String collectionId);
}

class CommentService implements CommentRepos {
  @override
  Future<List<Comment>?> fetchCommentsByStoryId(String storyId) async {
    String query = """
      query(
        \$storyId: ID
        \$myId: ID
      ){
        comments(
          orderBy:{
            published_date: desc
          }
          where:{
            story:{
              id:{
                equals: \$storyId
              }
            }
            is_active:{
              equals: true
            }
            state:{
              equals: "public"
            }
            member:{
              is_active:{
                equals: true
              }
            }
          }
        ){
          id
          member{
            id
            nickname
            email
            avatar
            avatar_image{
              id
              resized{
                original
              }
            }
          }
          content
          state
          published_date
          likeCount
          is_edited
          isLiked:likeCount(
            where:{
              is_active:{
                equals: true
              }
              id:{
                equals: \$myId
              }
            }
          )
        }
      }
      """;

    Map<String, String> variables = {
      "storyId": storyId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    try {
      final jsonResponse = await Get.find<GraphQLService>().query(
        api: Api.mesh,
        queryBody: query,
        variables: variables,
      );

      List<Comment> allComments = [];
      for (var item in jsonResponse.data!['comments']) {
        allComments.add(Comment.fromJson(item));
      }

      return allComments;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Comment>> fetchCommentsByCollectionId(String collectionId) async {
    String query = """
      query(
        \$collectionId: ID
        \$myId: ID
      ){
        comments(
          orderBy:{
            published_date: desc
          }
          where:{
            collection:{
              id:{
                equals: \$collectionId
              }
            }
            is_active:{
              equals: true
            }
            state:{
              equals: "public"
            }
            member:{
              is_active:{
                equals: true
              }
            }
          }
        ){
          id
          member{
            id
            nickname
            email
            avatar
            avatar_image{
              id
              resized{
                original
              }
            }
          }
          content
          state
          published_date
          likeCount
          is_edited
          isLiked:likeCount(
            where:{
              is_active:{
                equals: true
              }
              id:{
                equals: \$myId
              }
            }
          )
        }
      }
      """;

    Map<String, String> variables = {
      "collectionId": collectionId,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    List<Comment> allComments = [];
    for (var item in jsonResponse.data!['comments']) {
      allComments.add(Comment.fromJson(item));
    }

    return allComments;
  }
}
