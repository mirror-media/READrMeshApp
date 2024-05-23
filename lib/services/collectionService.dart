import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/addToCollectionItem.dart';
import 'package:readr/models/collection.dart';
import 'package:http/http.dart' as http;
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/models/timelineCollectionPick.dart';

abstract class CollectionRepos {
  Future<Map<String, List<CollectionPick>>> fetchPickAndBookmark({
    List<String>? fetchedBookmarkStoryIds,
    List<String>? fetchedPickStoryIds,
    String? keyWord,
  });

  Future<String> createOgPhoto({required String ogImageUrlOrPath});

  Future<Collection> createCollection({
    required String title,
    required String ogImageId,
    required List<CollectionPick> collectionPicks,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
    required String description,
  });

  Future<void> createCollectionPicks({
    required String collectionId,
    required List<CollectionPick> collectionPicks,
  });

  Future<void> updateTitle({
    required String collectionId,
    required String newTitle,
  });

  Future<void> updateOgPhoto(
      {required String photoId, required String ogImageUrlOrPath});

  Future<void> updateCollectionPicksData({
    required List<CollectionPick> collectionPicks,
  });

  Future<void> removeCollectionPicks(
      {required List<CollectionPick> collectionPicks});

  Future<bool> deleteCollection(String collectionId, String ogImageId);

  Future<Collection?> fetchCollectionById(String id);

  Future<void> updateDescription({
    required String collectionId,
    required String description,
  });

  Future<Map<String, List<AddToCollectionItem>>> fetchAndCheckOwnCollections(
      String tapStoryId);

  Future<void> addSingleStoryToCollection({
    required String storyId,
    required String collectionId,
    required int sortOrder,
    int? customYear,
    int? customMonth,
    int? customDay,
    DateTime? customTime,
  });

  Future<void> updateCollectionPicks({
    required String collectionId,
    required List<CollectionPick> originList,
    required List<CollectionPick> newList,
    required CollectionFormat format,
  });

  Future<void> updateCollectionFormat(
      {required String collectionId, required CollectionFormat format});
}

class CollectionService implements CollectionRepos {
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<Map<String, List<CollectionPick>>> fetchPickAndBookmark({
    List<String>? fetchedBookmarkStoryIds,
    List<String>? fetchedPickStoryIds,
    String? keyWord,
  }) async {
    const String query = """
    query(
      \$myId: ID
      \$fetchedBookmarkStoryIds: [ID!]
      \$fetchedPickStoryIds: [ID!]
      \$keyWord: String
      \$followingMembers: [ID!]
      \$blockAndBlockedIds: [ID!]
    ){
      bookmarks: picks(
        where:{
          member:{
            id:{
              equals: \$myId
            }
          }
          story:{
            is_active:{
              equals: true
            }
            id:{
              notIn: \$fetchedBookmarkStoryIds
            }
            title:{
              contains: \$keyWord
            }
          }
          is_active:{
            equals: true
          }
          objective:{
            equals: "story"
          }
          kind:{
            equals: "bookmark"
          }
        }
        take: 50
        orderBy:{
          picked_date: desc
        }
      ){
        picked_date
        story{
          id
          title
          url
          source{
            id
            title
          }
          full_content
          full_screen_ad
          paywall
          published_date
          createdAt
          og_image
          commentCount(
            where:{
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
                id:{
                  notIn: \$blockAndBlockedIds
                }
              }
            }
          )
          followingPicks: pick(
            where:{
              member:{
                id:{
                  in: \$followingMembers
                }
              }
              state:{
                equals: "public"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
            orderBy:{
              picked_date: desc
            }
            take: 4
          ){
            picked_date
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
          }
          otherPicks:pick(
            where:{
              member:{
                AND:[
                  {
                    id:{
                      notIn: \$followingMembers
                      not:{
                        equals: \$myId
                      }
                    }
                  }
                  {
                    id:{
                      notIn: \$blockAndBlockedIds
                    }
                  }
                  {
                    is_active:{
                      equals: true
                    }
                  }
                ]
              }
              state:{
                in: "public"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
            orderBy:{
              picked_date: desc
            }
            take: 4
          ){
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
          }
          pickCount(
            where:{
              state:{
                in: "public"
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
          )
        }
      }
      picks: picks(
        where:{
          member:{
            id:{
              equals: \$myId
            }
          }
          story:{
            is_active:{
              equals: true
            }
            id:{
              notIn: \$fetchedPickStoryIds
            }
            title:{
              contains: \$keyWord
            }
          }
          is_active:{
            equals: true
          }
          objective:{
            equals: "story"
          }
          kind:{
            equals: "read"
          }
        }
        take: 50
        orderBy:{
          picked_date: desc
        }
      ){
        picked_date
        story{
          id
          title
          url
          source{
            id
            title
          }
          full_content
          full_screen_ad
          paywall
          published_date
          createdAt
          og_image
          commentCount(
            where:{
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
                id:{
                  notIn: \$blockAndBlockedIds
                }
              }
            }
          )
          followingPicks: pick(
            where:{
              member:{
                id:{
                  in: \$followingMembers
                }
              }
              state:{
                equals: "public"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
            orderBy:{
              picked_date: desc
            }
            take: 4
          ){
            picked_date
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
          }
          otherPicks:pick(
            where:{
              member:{
                AND:[
                  {
                    id:{
                      notIn: \$followingMembers
                      not:{
                        equals: \$myId
                      }
                    }
                  }
                  {
                    id:{
                      notIn: \$blockAndBlockedIds
                    }
                  }
                  {
                    is_active:{
                      equals: true
                    }
                  }
                ]
              }
              state:{
                in: "public"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
            orderBy:{
              picked_date: desc
            }
            take: 4
          ){
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
          }
          pickCount(
            where:{
              state:{
                in: "public"
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
          )
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "fetchedBookmarkStoryIds": fetchedBookmarkStoryIds ?? [],
      "fetchedPickStoryIds": fetchedPickStoryIds ?? [],
      "keyWord": keyWord ?? '',
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<CollectionPick> pickAndBookmarkList = [];
    List<CollectionPick> pickList = [];
    List<CollectionPick> bookmarkList = [];

    for (var bookmark in jsonResponse.data!['bookmarks']) {
      CollectionPick collectionStory = CollectionPick.fromPick(bookmark);
      pickAndBookmarkList.add(collectionStory);
      bookmarkList.add(collectionStory);
    }
    for (var pick in jsonResponse.data!['picks']) {
      CollectionPick collectionStory = CollectionPick.fromPick(pick);
      pickList.add(collectionStory);
      int index = pickAndBookmarkList.indexWhere((element) =>
          element.newsListItem!.id == collectionStory.newsListItem!.id);
      if (index == -1) {
        pickAndBookmarkList.add(collectionStory);
      }
    }

    pickAndBookmarkList.sort((a, b) => b.pickedDate!.compareTo(a.pickedDate!));

    return {
      'pickAndBookmarkList': pickAndBookmarkList,
      'pickList': pickList,
      'bookmarkList': bookmarkList,
    };
  }

  @override
  Future<String> createOgPhoto({required String ogImageUrlOrPath}) async {
    const String urlMutation = """
mutation(
  \$photoName: String
  \$imageUrl: String
){
  createPhoto(
    data:{
      name: \$photoName
      urlOriginal: \$imageUrl
    }
  ){
    id
  }
}
""";

    const String photoMutation = """
mutation(
  \$photoName: String
  \$imageFile: Upload
){
  createPhoto(
    data:{
      name: \$photoName
     	file:{
        upload: \$imageFile
      }
    }
  ){
    id
  }
}
""";

    String mutation;
    Map<String, dynamic> variables;

    if (ogImageUrlOrPath.contains('http')) {
      mutation = urlMutation;
      variables = {
        'photoName': 'CollectionOg_${DateTime.now()}_$hashCode',
        'imageUrl': ogImageUrlOrPath,
      };
    } else {
      final multipartFile = await http.MultipartFile.fromPath(
        '',
        ogImageUrlOrPath,
        contentType: MediaType("image", 'jpg'),
      );
      mutation = photoMutation;
      variables = {
        'photoName': 'CollectionOg_${DateTime.now()}',
        'imageFile': multipartFile,
      };
    }

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.toString());
    }

    return result.data!['createPhoto']['id'];
  }

  @override
  Future<Collection> createCollection({
    required String title,
    required String ogImageId,
    required List<CollectionPick> collectionPicks,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
    required String description,
  }) async {
    const String mutation = """
    mutation(
  \$title: String
  \$slug: String
  \$myId: ID
  \$public: String
  \$format: String
  \$photoId: ID
  \$collectionpicks: [CollectionPickCreateInput!]
  \$followingMembers: [ID!]
  \$description: String
  \$blockAndBlockedIds: [ID!]
){
  createCollection(
    data:{
      title: \$title,
      slug: \$slug,
      public: \$public,
      format: \$format,
      status: "publish"
      summary: \$description,
      creator:{
      	connect:{
          id: \$myId
        }
      }
      heroImage:{
        connect:{
          id: \$photoId
        }
      }
      collectionpicks:{
        create: \$collectionpicks
      }
    }
  ){
    id
    title
    slug
    public
    status
    summary
    heroImage{
      id
      resized{
        original
      }
    }
    format
    createdAt
    updatedAt
    collectionpicks(
      orderBy:{
        sort_order: asc
      }
    ){
      id
      sort_order
      picked_date
      custom_year
      custom_month
      custom_day
      custom_time
      summary
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
      story{
        id
        title
        url
        source{
          id
          title
        }
        full_content
        full_screen_ad
        paywall
        published_date
        createdAt
        og_image
        followingPicks: pick(
          where:{
            member:{
              id:{
                in: \$followingMembers
              }
            }
            state:{
              equals: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
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
        }
        otherPicks:pick(
          where:{
            member:{
              AND:[
                {
                  id:{
                    notIn: \$followingMembers
                    not:{
                      equals: \$myId
                    }
                  }
                }
                {
                  id:{
                    notIn: \$blockAndBlockedIds
                  }
                }
                {
                  is_active:{
                    equals: true
                  }
                }
              ]
            }
            state:{
              in: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
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
        }
        pickCount(
          where:{
            state:{
              in: "public"
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
        )
        commentCount(
          where:{
            state:{
              in: "public"
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
        )
      }
    }
  }
}
    """;

    List<Map<String, dynamic>> collectionStoryList = [];
    for (var item in collectionPicks) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.pickNewsId}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String(),
        "custom_year": item.customYear,
        "custom_month": item.customMonth,
        "custom_day": item.customDay,
        "custom_time": item.customTime?.toUtc().toIso8601String(),
        "summary": item.summary ?? '',
      };
      collectionStoryList.add(createInput);
    }

    Map<String, dynamic> variables = {
      "title": title,
      "slug": slug ?? '${DateTime.now()}_$hashCode',
      "public": public.toString().split('.').last,
      "format": format.toString().split('.').last,
      "myId": Get.find<UserService>().currentUser.memberId,
      "photoId": ogImageId,
      "collectionpicks": collectionStoryList,
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "description": description,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    if (result.hasException || result.data == null) {
      throw Exception(result.exception?.graphqlErrors.toString());
    }

    final jsonResponse = result.data;

    List<CollectionPick> collectionPickList = [];
    switch (format) {
      case CollectionFormat.folder:
        for (var result in jsonResponse!['createCollection']
            ['collectionpicks']) {
          collectionPickList.add(FolderCollectionPick.fromJson(result));
        }
        break;
      case CollectionFormat.timeline:
        for (var result in jsonResponse!['createCollection']
            ['collectionpicks']) {
          collectionPickList.add(TimelineCollectionPick.fromJson(result));
        }
        break;
    }

    Collection collection = Collection.fromJsonWithMember(
        jsonResponse['createCollection'], Get.find<UserService>().currentUser);
    collection.collectionPicks = collectionPickList;

    return collection;
  }

  @override
  Future<void> updateCollectionPicks({
    required String collectionId,
    required List<CollectionPick> originList,
    required List<CollectionPick> newList,
    required CollectionFormat format,
  }) async {
    List<CollectionPick> addItemList = [];
    List<CollectionPick> moveItemList = [];
    List<CollectionPick> deleteItemList = [];

    for (int i = 0; i < newList.length; i++) {
      newList[i].sortOrder = i;
      int indexInOldList = originList
          .indexWhere((element) => element.pickNewsId == newList[i].pickNewsId);
      if (indexInOldList == -1) {
        addItemList.addIf(
            !addItemList
                .any((element) => element.pickNewsId == newList[i].pickNewsId),
            newList[i]);
      } else {
        moveItemList.addIf(
            !moveItemList
                .any((element) => element.pickNewsId == newList[i].pickNewsId),
            newList[i]);
        originList.removeAt(indexInOldList);
      }
    }

    if (originList.isNotEmpty) {
      deleteItemList.assignAll(originList);
    }

    //check repeat
    for (var item in moveItemList) {
      addItemList
          .removeWhere((element) => element.pickNewsId == item.pickNewsId);
    }

    await Future.wait([
      if (addItemList.isNotEmpty)
        createCollectionPicks(
          collectionId: collectionId,
          collectionPicks: addItemList,
        ),
      if (moveItemList.isNotEmpty)
        updateCollectionPicksData(
          collectionPicks: moveItemList,
        ),
      if (deleteItemList.isNotEmpty)
        removeCollectionPicks(
          collectionPicks: deleteItemList,
        ),
      updateCollectionFormat(collectionId: collectionId, format: format),
    ]);
  }

  @override
  Future<void> createCollectionPicks({
    required String collectionId,
    required List<CollectionPick> collectionPicks,
  }) async {
    const String mutation = """
    mutation(
      \$data: [CollectionPickCreateInput!]!
    ){
      createCollectionPicks(
        data:\$data
      ){
        id
      }
    }
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<Map<String, dynamic>> dataList = [];
    for (var item in collectionPicks) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.pickNewsId}
        },
        "collection": {
          "connect": {"id": collectionId}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String(),
        "custom_year": item.customYear,
        "custom_month": item.customMonth,
        "custom_day": item.customDay,
        "custom_time": item.customTime?.toUtc().toIso8601String(),
        "summary": item.summary ?? '',
      };
      dataList.add(createInput);
    }

    Map<String, dynamic> variables = {
      "data": dataList,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> updateOgPhoto(
      {required String photoId, required String ogImageUrlOrPath}) async {
    const String urlMutation = """
mutation(
  \$photoId: ID
  \$newPhotoUrl: String
){
 updatePhoto(
    where:{
      id: \$photoId
    }
    data:{
      urlOriginal: \$newPhotoUrl
    }
  ){
    id
  }
}
""";

    const String photoMutation = """
mutation(
  \$photoId: ID
  \$image: Upload
){
 updatePhoto(
    where:{
      id: \$photoId
    }
    data:{
      urlOriginal: ""
      file:{
        upload: \$image
      }
    }
  ){
    id
  }
}
""";

    String mutation;
    final Map<String, dynamic> variables = {'photoId': photoId};

    if (ogImageUrlOrPath.contains('http')) {
      mutation = urlMutation;
      variables['newPhotoUrl'] = ogImageUrlOrPath;
    } else {
      final multipartFile = await http.MultipartFile.fromPath(
        '',
        ogImageUrlOrPath,
        contentType: MediaType("image", 'jpg'),
      );
      mutation = photoMutation;
      variables['image'] = multipartFile;
    }

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> updateTitle({
    required String collectionId,
    required String newTitle,
  }) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$newTitle: String
){
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      title: \$newTitle
    }
  ){
    id
    title
    heroImage{
      id
      resized{
        original
      }
    }
    updatedAt
  }
}
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "newTitle": newTitle,
    };

    final jsonResponse = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    final json = jsonResponse.data!['updateCollection'];

    final controller =
        Get.find<PickableItemController>(tag: 'Collection${json['id']}');
    controller.collectionTitle.value = json['title'];
    controller.collectionHeroImageUrl.value =
        json['heroImage']['resized']['original'];
    controller.collectionUpdatetime.value = DateTime.parse(json['updatedAt']);
  }

  @override
  Future<void> updateCollectionPicksData({
    required List<CollectionPick> collectionPicks,
  }) async {
    const String mutation = """
mutation(
  \$data: [CollectionPickUpdateArgs!]!
){
  updateCollectionPicks(
    data: \$data
  ){
    id
  }
}
    """;

    List<Map> dataList = [];

    for (var item in collectionPicks) {
      dataList.add({
        "where": {"id": item.id},
        "data": {
          "sort_order": item.sortOrder,
          "updated_date": DateTime.now().toUtc().toIso8601String(),
          "custom_year": item.customYear,
          "custom_month": item.customMonth,
          "custom_day": item.customDay,
          "custom_time": item.customTime?.toUtc().toIso8601String(),
          "summary": item.summary ?? '',
        }
      });
    }

    Map<String, dynamic> variables = {
      "data": dataList,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> removeCollectionPicks(
      {required List<CollectionPick> collectionPicks}) async {
    const String mutation = """
mutation(
  \$data: [CollectionPickWhereUniqueInput!]!
){
  deleteCollectionPicks(
    where: \$data
  ){
    id
  }
}
    """;

    List<Map> dataList = [];

    for (var item in collectionPicks) {
      dataList.add(
        {"id": item.id},
      );
    }

    Map<String, dynamic> variables = {
      "data": dataList,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<bool> deleteCollection(String collectionId, String ogImageId) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$heroImageId: ID
){
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      status: "delete"
      heroImage:{
        disconnect: true
      }
    }
  ){
    status
  }
  deletePhoto(
    where:{
      id: \$heroImageId
    }
  ){
    id
  }
}
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "heroImageId": ogImageId,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    return true;
  }

  @override
  Future<Collection?> fetchCollectionById(String id) async {
    const String query = """
    query(
      \$collectionId: ID
      \$followingMembers: [ID!]
      \$myId: ID
      \$blockAndBlockedIds: [ID!]
    ){
      collection(
        where:{
          id: \$collectionId
        }
      ){
        id
        title
        slug
        public
        status
        summary
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
        heroImage{
          id
          urlOriginal
          file{
            url
          }
        }
        format
        createdAt
        updatedAt
        commentCount(
          where:{
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
              id:{
                notIn: \$blockAndBlockedIds
              }
            }
          }
        )
        followingPicks: picks(
          where:{
            member:{
              id:{
                in: \$followingMembers
              }
            }
            state:{
              equals: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
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
        }
        otherPicks:picks(
          where:{
            member:{
              AND:[
                {
                  id:{
                    notIn: \$followingMembers
                    not:{
                      equals: \$myId
                    }
                  }
                }
                {
                  id:{
                    notIn: \$blockAndBlockedIds
                  }
                }
                {
                  is_active:{
                    equals: true
                  }
                }
              ]
            }
            state:{
              in: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
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
        }
        picksCount(
          where:{
            state:{
              in: "public"
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
        )
      }
    }
    """;

    Map<String, dynamic> variables = {
      "collectionId": id,
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "blockAndBlockedIds": Get.find<UserService>().blockAndBlockedIds,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    if (jsonResponse.data!['collection'] != null) {
      return Collection.fromJson(jsonResponse.data!['collection']);
    }

    return null;
  }

  @override
  Future<void> updateDescription({
    required String collectionId,
    required String description,
  }) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$description: String
){
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      summary: \$description
    }
  ){
    id
    updatedAt
  }
}
""";

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "description": description,
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.toString());
    } else {
      Get.find<PickableItemController>(tag: 'Collection$collectionId')
              .collectionUpdatetime
              .value =
          DateTime.tryParse(result.data!['updateCollection']['updatedAt']) ??
              DateTime.now();
    }
  }

  @override
  Future<Map<String, List<AddToCollectionItem>>> fetchAndCheckOwnCollections(
      String tapStoryId) async {
    const String query = """
query(
  \$myId: ID
  \$tapStoryId: ID
){
  alreadyPickCollections: collections(
    where:{
      creator:{
        id:{
          equals: \$myId
        }
      }
      status:{
      	equals: "publish"
      }
      collectionpicks:{
        some:{
          story:{
            id:{
              equals: \$tapStoryId
            }
          }
        }
      }
    }
    orderBy:[
      {updatedAt: desc},{createdAt: desc}
    ]
  ){
    title
  }
  notPickCollections: collections(
    where:{
      creator:{
        id:{
          equals: \$myId
        }
      }
      status:{
      	equals: "publish"
      }
      collectionpicks:{
        none:{
          story:{
            id:{
              equals: \$tapStoryId
            }
          }
        }
      }
    }
    orderBy:[
      {updatedAt: desc},{createdAt: desc}
    ]
  ){
    id
    title
    format
    heroImage{
      resized{
        original
      }
    }
    collectionpicks(
      orderBy:[{sort_order: asc}]
    ){
      id
      sort_order
      custom_year
      custom_month
      custom_day
      custom_time
      story{
        id
      }
    }
  }
}
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "tapStoryId": tapStoryId,
    };

    final result =
        await proxyServerService.gql(query: query, variables: variables);

    List<AddToCollectionItem> alreadyPickCollections = [];
    List<AddToCollectionItem> notPickCollections = [];

    for (var item in result.data!['alreadyPickCollections']) {
      alreadyPickCollections
          .add(AddToCollectionItem.fromAlreadyPickedCollection(item));
    }

    for (var item in result.data!['notPickCollections']) {
      notPickCollections.add(AddToCollectionItem.fromNotPickedCollection(item));
    }

    return {
      'alreadyPickCollections': alreadyPickCollections,
      'notPickCollections': notPickCollections,
    };
  }

  @override
  Future<void> addSingleStoryToCollection({
    required String storyId,
    required String collectionId,
    required int sortOrder,
    int? customYear,
    int? customMonth,
    int? customDay,
    DateTime? customTime,
  }) async {
    const String mutation = """
mutation(
  \$data: CollectionPickCreateInput!
  \$collectionUpdateTime: DateTime
  \$collectionId: ID
){
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      updatedAt: \$collectionUpdateTime
    }
  ){
    id
  }
  createCollectionPick(
    data: \$data
  ){
    id
  }
}
    """;

    Map<String, dynamic> variables = {
      "data": {
        "story": {
          "connect": {"id": storyId},
        },
        "collection": {
          "connect": {"id": collectionId},
        },
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId},
        },
        "picked_date": DateTime.now().toUtc().toIso8601String(),
        "sort_order": sortOrder,
        "custom_year": customYear,
        "custom_month": customMonth,
        "custom_day": customDay,
        "custom_time": customTime?.toUtc().toIso8601String(),
      },
      "collectionUpdateTime": DateTime.now().toUtc().toIso8601String(),
      "collectionId": collectionId,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> updateCollectionFormat({
    required String collectionId,
    required CollectionFormat format,
  }) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$format: String
){
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      format: \$format
    }
  ){
    format
  }
}
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "format": format.toString().split('.').last,
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }
}
