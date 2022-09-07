import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/announcement.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/notify.dart';
import 'package:readr/models/notifyPageItem.dart';

abstract class NotifyRepos {
  Future<List<Notify>> fetchNotifies({List<String>? alreadyFetchNotifyIds});
  Future<List<NotifyPageItem>> fetchNotifyRelatedItems(
      List<NotifyPageItem> pageItemList);
  Future<List<Announcement>> fetchAnnouncements();
}

class NotifyService implements NotifyRepos {
  @override
  Future<List<Notify>> fetchNotifies(
      {List<String>? alreadyFetchNotifyIds}) async {
    const String query = """
query(
  \$alreadyFetchedIds: [ID!]
  \$TimeFilter: DateTime
  \$myId: ID
){
	notifies(
    orderBy:{
      action_date: desc
    }
    where:{
      id:{
        notIn: \$alreadyFetchedIds
      }
      action_date:{
        gte: \$TimeFilter
      }
      member:{
        id:{
          equals: \$myId
        }
      }
      sender:{
        is_active:{
          equals: true
        }
      }
    }
  ){
    id
   	sender{
      id
      nickname
      avatar
      customId
      avatar_image{
        id
        resized{
          original
        }
      }
    }
    type
    objective
    object_id
    action_date
    state
  }
}
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "TimeFilter": DateTime.now()
          .subtract(const Duration(days: 7))
          .toUtc()
          .toIso8601String(),
      "alreadyFetchedIds": alreadyFetchNotifyIds ?? [],
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    List<Notify> notifications = [];

    try {
      notifications = List<Notify>.from(jsonResponse.data!['notifies']
          .map((element) => Notify.fromJson(element)));
    } catch (e) {
      print('Fetch notify error: $e');
    }

    return notifications;
  }

  @override
  Future<List<Announcement>> fetchAnnouncements() async {
    const String query = """
query{
  announcements(
    orderBy:{
      createdAt: desc
    }
    where:{
      status:{
        equals: "published"
      }
    }
  ){
    name
    type
  }
}
    """;
    List<Announcement> announcements = [];

    try {
      final jsonResponse = await Get.find<GraphQLService>()
          .query(api: Api.mesh, queryBody: query);

      for (var item in jsonResponse.data!['announcements']) {
        announcements.add(Announcement.fromJson(item));
      }
    } catch (e) {
      print('Fetch announcements error: $e');
    }

    return announcements;
  }

  @override
  Future<List<NotifyPageItem>> fetchNotifyRelatedItems(
      List<NotifyPageItem> pageItemList) async {
    const String query = """
query(
  \$collectionIds: [ID!]
  \$commentIds: [ID!]
  \$storyIds: [ID!]
  \$blockAndBlockedIds: [ID!]
){
  stories(
   where:{
    id:{
      in: \$storyIds
    }
    is_active:{
      equals: true
    }
  } 
  ){
    id
    title
    url
    source{
      id
      title
    }
    published_date
    createdAt
    og_image
  }
  collections(
    where:{
      id:{
        in: \$collectionIds
      }
      status:{
        equals: "publish"
      }
      creator:{
        id:{
          notIn: \$blockAndBlockedIds
        }
      }
    }
  ){
    id
    title
    slug
    status
    createdAt
    public
    heroImage{
      id
      resized{
        original
      }
    }
    format
    creator{
      id
      nickname
      avatar
      customId
      avatar_image{
        id
        resized{
          original
        }
      }
    }
  }
  comments(
    where:{
      id:{
        in: \$commentIds 
      }
      is_active:{
        equals: true
      }
      member:{
        id:{
          notIn: \$blockAndBlockedIds
        }
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
      avatar
      customId
      avatar_image{
        id
        resized{
          original
        }
      }
    }
    content
    published_date
    state
    story{
      id
    	title
    	url
    	source{
      	id
      	title
    	}
    	published_date
    	createdAt
    	og_image
      is_active
    }
    collection{
      id
    	title
   	 	slug
    	status
    	createdAt
    	public
    	heroImage{
      	id
      	resized{
          original
        }
    	}
    	format
      creator{
        id
        nickname
        avatar
        customId
        avatar_image{
          id
          resized{
            original
          }
        }
      }
    }
  }
}
    """;

    List<String> storyIds = [];
    List<String> collectionIds = [];
    List<String> commentIds = [];

    for (var item in pageItemList) {
      switch (item.type) {
        case NotifyType.comment:
          storyIds.addIf(!storyIds.any((element) => element == item.objectId),
              item.objectId);
          break;
        case NotifyType.follow:
          break;
        case NotifyType.like:
          commentIds.addIf(
              !commentIds.any((element) => element == item.objectId),
              item.objectId);
          break;
        case NotifyType.pickCollection:
        case NotifyType.commentCollection:
        case NotifyType.createCollection:
          collectionIds.addIf(
              !collectionIds.any((element) => element == item.objectId),
              item.objectId);
          break;
      }
    }

    Map<String, dynamic> variables = {
      "collectionIds": collectionIds,
      "commentIds": commentIds,
      "storyIds": storyIds,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    for (var collectionItem in jsonResponse.data!['collections']) {
      Collection collection = Collection.fromJson(collectionItem);
      pageItemList
          .firstWhereOrNull((element) =>
              (element.type == NotifyType.pickCollection ||
                  element.type == NotifyType.createCollection) &&
              element.objectId == collection.id)
          ?.collection = collection;
    }

    for (var storyItem in jsonResponse.data!['stories']) {
      NewsListItem news = NewsListItem.fromJson(storyItem);
      pageItemList
          .firstWhereOrNull((element) =>
              element.type == NotifyType.comment && element.objectId == news.id)
          ?.newsListItem = news;
    }

    for (var commentItem in jsonResponse.data!['comments']) {
      Comment comment = Comment.fromJson(commentItem);
      int index = pageItemList.indexWhere((element) =>
          element.objectId == comment.id && element.type == NotifyType.like);
      if (commentItem['story'] != null &&
          commentItem['story']['is_active'] &&
          index != -1) {
        NewsListItem news = NewsListItem.fromJson(commentItem['story']);
        pageItemList[index].comment = comment;
        pageItemList[index].newsListItem = news;
      } else if (commentItem['collection'] != null &&
          commentItem['collection']['status'] == 'publish' &&
          index != -1) {
        Collection collection = Collection.fromJson(commentItem['collection']);
        pageItemList[index].comment = comment;
        pageItemList[index].collection = collection;
      }
    }

    pageItemList.removeWhere((element) =>
        element.type != NotifyType.follow &&
        element.newsListItem == null &&
        element.collection == null);

    return pageItemList;
  }
}
