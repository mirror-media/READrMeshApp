import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/addToCollectionItem.dart';
import 'package:readr/models/collection.dart';
import 'package:http/http.dart' as http;
import 'package:readr/models/collectionStory.dart';

abstract class CollectionRepos {
  Future<Map<String, List<CollectionStory>>> fetchPickAndBookmark({
    List<String>? fetchedBookmarkStoryIds,
    List<String>? fetchedPickStoryIds,
    String? keyWord,
  });
  Future<String> createOgPhoto({required String ogImageUrlOrPath});
  Future<Collection> createCollection({
    required String title,
    required String ogImageId,
    required List<CollectionStory> collectionStory,
    CollectionFormat format = CollectionFormat.folder,
    CollectionPublic public = CollectionPublic.public,
    String? slug,
    required String description,
  });
  Future<List<CollectionStory>> createCollectionPicks({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  });
  Future<Collection> updateTitle({
    required String collectionId,
    required String newTitle,
  });
  Future<void> updateOgPhoto(
      {required String photoId, required String ogImageUrlOrPath});
  Future<void> updateCollectionPicksOrder({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  });
  Future<void> removeCollectionPicks(
      {required List<CollectionStory> collectionStory});
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
  });
}

class CollectionService implements CollectionRepos {
  @override
  Future<Map<String, List<CollectionStory>>> fetchPickAndBookmark({
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
                id:{
                  notIn: \$followingMembers
                  not:{
                    equals: \$myId
                  }
                }
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
            }
          )
          myPickId: pick(
            where:{
              member:{
                id:{
                  equals: \$myId
                }
              }
              state:{
                notIn: "private"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
          ){
            id
            pick_comment(
              where:{
                is_active:{
                  equals: true
                }
              }
            ){
              id
            }
          }
          comment(
            where:{
              is_active:{
                equals: true
              }
              state:{
                equals: "public"
              }
              member:{
                id:{
                  in: \$followingMembers
                  not:{
                    equals: \$myId
                  }
                }
              }
            }
            orderBy:{
              published_date: desc
            }
            take: 2
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
            state
            published_date
            likeCount(
              where:{
                is_active:{
                  equals: true
                }
              }
            )
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
                id:{
                  notIn: \$followingMembers
                  not:{
                    equals: \$myId
                  }
                }
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
            }
          )
          myPickId: pick(
            where:{
              member:{
                id:{
                  equals: \$myId
                }
              }
              state:{
                notIn: "private"
              }
              kind:{
                equals: "read"
              }
              is_active:{
                equals: true
              }
            }
          ){
            id
            pick_comment(
              where:{
                is_active:{
                  equals: true
                }
              }
            ){
              id
            }
          }
          comment(
            where:{
              is_active:{
                equals: true
              }
              state:{
                equals: "public"
              }
              member:{
                id:{
                  in: \$followingMembers
                  not:{
                    equals: \$myId
                  }
                }
              }
            }
            orderBy:{
              published_date: desc
            }
            take: 2
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
            state
            published_date
            likeCount(
              where:{
                is_active:{
                  equals: true
                }
              }
            )
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
      }
    }
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "fetchedBookmarkStoryIds": fetchedBookmarkStoryIds ?? [],
      "fetchedPickStoryIds": fetchedPickStoryIds ?? [],
      "keyWord": keyWord ?? '',
      "followingMembers": Get.find<UserService>().followingMemberIds,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

    List<CollectionStory> pickAndBookmarkList = [];
    List<CollectionStory> pickList = [];
    List<CollectionStory> bookmarkList = [];

    for (var bookmark in jsonResponse.data!['bookmarks']) {
      CollectionStory collectionStory = CollectionStory.fromPick(bookmark);
      pickAndBookmarkList.add(collectionStory);
      bookmarkList.add(collectionStory);
    }
    for (var pick in jsonResponse.data!['picks']) {
      CollectionStory collectionStory = CollectionStory.fromPick(pick);
      pickList.add(collectionStory);
      int index = pickAndBookmarkList
          .indexWhere((element) => element.news.id == collectionStory.news.id);
      if (index == -1) {
        pickAndBookmarkList.add(collectionStory);
      }
    }

    pickAndBookmarkList.sort((a, b) => b.pickedDate.compareTo(a.pickedDate));

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
    required List<CollectionStory> collectionStory,
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
    slug
    createdAt
    heroImage{
      id
      resized{
        original
      }
    }
    collectionpicks{
      id
      sort_order
      picked_date
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
              id:{
                notIn: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
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
          }
        )
        myPickId: pick(
          where:{
            member:{
              id:{
                equals: \$myId
              }
            }
            state:{
              notIn: "private"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
        ){
          id
          pick_comment(
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
    }
  }
}
    """;

    List<Map<String, dynamic>> collectionStoryList = [];
    for (var item in collectionStory) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.news.id}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String()
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
    };

    final result = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    if (result.hasException || result.data == null) {
      throw Exception(result.exception?.graphqlErrors.toString());
    }

    final jsonResponse = result.data;

    List<CollectionStory> collectionPicks = [];
    for (var result in jsonResponse!['createCollection']['collectionpicks']) {
      collectionPicks.add(CollectionStory.fromJson(result));
    }

    return Collection(
      id: jsonResponse['createCollection']['id'],
      title: title,
      slug: jsonResponse['createCollection']['slug'],
      creator: Get.find<UserService>().currentUser,
      format: format,
      public: public,
      controllerTag: 'Collection${jsonResponse['createCollection']['id']}',
      ogImageUrl: jsonResponse['createCollection']['heroImage']['resized']
          ['original'],
      updateTime:
          DateTime.tryParse(jsonResponse['createCollection']['createdAt']) ??
              DateTime.now(),
      collectionPicks: collectionPicks,
      ogImageId: jsonResponse['createCollection']['heroImage']['id'],
    );
  }

  @override
  Future<List<CollectionStory>> createCollectionPicks({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  }) async {
    const String mutation = """
    mutation(
      \$myId: ID
      \$followingMembers: [ID!]
      \$data: [CollectionPickCreateInput!]!
    ){
      createCollectionPicks(
        data:\$data
      ){
        id
        sort_order
        picked_date
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
                  id:{
                    notIn: \$followingMembers
                    not:{
                      equals: \$myId
                    }
                  }
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
              }
            )
            myPickId: pick(
              where:{
                member:{
                  id:{
                    equals: \$myId
                  }
                }
                state:{
                  notIn: "private"
                }
                kind:{
                  equals: "read"
                }
                is_active:{
                  equals: true
                }
              }
            ){
              id
              pick_comment(
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
      }
    }
    """;

    List<String> followingMemberIds = [];
    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    List<Map<String, dynamic>> dataList = [];
    for (var item in collectionStory) {
      Map<String, dynamic> createInput = {
        "story": {
          "connect": {"id": item.news.id}
        },
        "collection": {
          "connect": {"id": collectionId}
        },
        "sort_order": item.sortOrder,
        "creator": {
          "connect": {"id": Get.find<UserService>().currentUser.memberId}
        },
        "picked_date": DateTime.now().toUtc().toIso8601String()
      };
      dataList.add(createInput);
    }

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "followingMembers": followingMemberIds,
      "data": dataList,
    };

    final jsonResponse = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    List<CollectionStory> collectionPicks = [];
    for (var result in jsonResponse.data!['createCollectionPicks']) {
      collectionPicks.add(CollectionStory.fromJson(result));
    }

    return collectionPicks;
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
  Future<Collection> updateTitle({
    required String collectionId,
    required String newTitle,
  }) async {
    const String mutation = """
mutation(
  \$collectionId: ID
  \$newTitle: String
  \$followingMembers: [ID!]
  \$myId: ID
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
          id:{
            notIn: \$followingMembers
            not:{
              equals: \$myId
            }
          }
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
      }
    )
    myPickId: picks(
      where:{
        member:{
          id:{
            equals: \$myId
          }
        }
        state:{
          notIn: "private"
        }
        kind:{
          equals: "read"
        }
        is_active:{
          equals: true
        }
      }
    ){
      id
      pick_comment(
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
}
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "newTitle": newTitle,
      "myId": Get.find<UserService>().currentUser.memberId,
      "followingMembers": Get.find<UserService>().followingMemberIds,
    };

    final jsonResponse = await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );

    return Collection.fromFetchCollectionList(
        jsonResponse.data!['updateCollection'],
        Get.find<UserService>().currentUser);
  }

  @override
  Future<void> updateCollectionPicksOrder({
    required String collectionId,
    required List<CollectionStory> collectionStory,
  }) async {
    const String mutation = """
mutation(
  \$data: [CollectionPickUpdateArgs!]!
  \$updateTime: DateTime
  \$collectionId: ID
){
  updateCollectionPicks(
    data: \$data
  ){
    id
  }
  updateCollection(
    where:{
      id: \$collectionId
    }
    data:{
      updatedAt:\$updateTime
    }
  ){
    updatedAt
  }
}
    """;

    List<Map> dataList = [];

    for (var item in collectionStory) {
      dataList.add({
        "where": {"id": item.id},
        "data": {
          "sort_order": item.sortOrder,
          "updated_date": DateTime.now().toUtc().toIso8601String(),
        }
      });
    }

    Map<String, dynamic> variables = {
      "data": dataList,
      "collectionId": collectionId,
      "updateTime": DateTime.now().toUtc().toIso8601String()
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }

  @override
  Future<void> removeCollectionPicks(
      {required List<CollectionStory> collectionStory}) async {
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

    for (var item in collectionStory) {
      dataList.add({
        "where": {"id": item.id},
        "data": {
          "collection": {"disconnect": true}
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
              id:{
                notIn: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
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
          }
        )
        myPickId: picks(
          where:{
            member:{
              id:{
                equals: \$myId
              }
            }
            state:{
              notIn: "private"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
        ){
          id
          pick_comment(
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
    }
    """;

    Map<String, dynamic> variables = {
      "collectionId": id,
      "followingMembers": Get.find<UserService>().followingMemberIds,
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

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
    heroImage{
      resized{
        original
      }
    }
    collectionpicksCount
  }
}
    """;

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
      "tapStoryId": tapStoryId,
    };

    final result = await Get.find<GraphQLService>().query(
      api: Api.mesh,
      queryBody: query,
      variables: variables,
    );

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
  }) async {
    const String mutation = """
mutation(
  \$sortOrder: Int
  \$storyId: ID
  \$collectionId: ID
  \$myId: ID
  \$pickedDate: DateTime
){
  createCollectionPick(
    data:{
      story:{
        connect:{
          id: \$storyId
        }
      }
      collection:{
        connect:{
          id: \$collectionId
        }
      }
      creator:{
        connect:{
          id: \$myId
        }
      }
      picked_date: \$pickedDate
      sort_order: \$sortOrder
    }
  ){
    id
  }
}
    """;

    Map<String, dynamic> variables = {
      "collectionId": collectionId,
      "sortOrder": sortOrder,
      "storyId": storyId,
      "myId": Get.find<UserService>().currentUser.memberId,
      "pickedDate": DateTime.now().toUtc().toIso8601String(),
    };

    await Get.find<GraphQLService>().mutation(
      mutationBody: mutation,
      variables: variables,
    );
  }
}
