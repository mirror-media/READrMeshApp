import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/story.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:readr/models/storyListItemList.dart';

abstract class StoryRepos {
  Future<Story> fetchPublishedStoryById(String id);
  Future<StoryListItemList> fetchRecommenedStoryList(
      String id, List<String> categoriesSlug, List<String> tagsName);
  Future<StoryListItemList> fetchLatestStoryList(
      List<String> idList, int first);
  bool hasSameCategories(
      StoryListItem storyListItem, List<String> categoriesSlug);
  bool hasSameTags(StoryListItem storyListItem, List<String> tagsName);
}

class StoryServices implements StoryRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Story> fetchPublishedStoryById(String id) async {
    final key = 'fetchPublishedStoryById?id=$id';

    const String query = """
    query (
      \$where: PostWhereInput,
    ) {
      allPosts(
        where: \$where
      ) {
        style
        name
        wordCount
        summaryApiData
        contentApiData
        citationApiData
        publishTime
        updatedAt
        heroImage {
          mobile: urlMobileSized
          desktop: urlDesktopSized
        }
        heroVideo {
          coverPhoto {
            tiny: urlTinySized
            mobile: urlMobileSized
            tablet: urlTabletSized
            desktop: urlDesktopSized
            original: urlOriginal
          }
          file {
            publicUrl
          }
          url
        }
        heroCaption
        categories {
          id
          slug
          name
        }
        writers {
          name
          slug
        }
        photographers {
          name
          slug
        }
        cameraOperators {
          name
          slug
        }
        designers {
          name
          slug
        }
        engineers {
          name 
          slug
        }
        dataAnalysts{
          name
          slug
        }
        otherByline
        tags {
          id
          name
          slug
        }
        relatedPosts {
          id
          slug
          name
          publishTime
          style
          wordCount
          categories(where: {
            state: active
          }){
            id
            name
            slug
          }
          heroImage {
            urlMobileSized
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"state": "published", "id": id},
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: newsStoryCacheDuration,
        headers: {"Content-Type": "application/json"});

    Story story;
    try {
      story = Story.fromJson(jsonResponse['data']['allPosts'][0]);
      List<String> categoriesSlug = [];
      List<String> tagsSlug = [];
      story.categoryList?.forEach((element) {
        categoriesSlug.add(element.slug);
      });
      story.tags?.forEach((element) {
        tagsSlug.add(element.slug);
      });
      story.recommendedStories =
          await fetchRecommenedStoryList(id, categoriesSlug, tagsSlug);
    } catch (e) {
      throw FormatException(e.toString());
    }

    return story;
  }

  @override
  Future<StoryListItemList> fetchRecommenedStoryList(
      String id, List<String> categoriesSlug, List<String> tagsSlug) async {
    final key = 'fetchRecommenedStoryExclude$id';

    const String query = """
    query (
      \$where: PostWhereInput,
    ) {
      allPosts(
        where: \$where,
        first: 4, 
        sortBy: [ publishTime_DESC ]
      ) {
        id
        slug
        name
        publishTime
        style
        wordCount
        heroImage {
          urlMobileSized
        }
        categories(where: {
            state: active
          }){
            id
            name
            slug
        }
        tags {
          id
          name
          slug
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "id_not": id,
        "state": "published",
        "OR": [
          {
            "categories_some": {"slug_in": categoriesSlug}
          },
          {
            "tags_some": {"slug_in": tagsSlug}
          }
        ]
      }
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: newsStoryCacheDuration,
        headers: {"Content-Type": "application/json"});

    StoryListItemList recommenedStoryList;

    if (jsonResponse['data']['allPosts'].length > 0) {
      recommenedStoryList =
          StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
      recommenedStoryList.sort((a, b) {
        bool aIsSameCategory = hasSameCategories(a, categoriesSlug);
        bool aIsSameTag = hasSameTags(a, tagsSlug);
        bool bIsSameCategory = hasSameCategories(b, categoriesSlug);
        bool bIsSameTag = hasSameTags(b, tagsSlug);
        int aPriority = 4;
        int bPriority = 4;
        if (aIsSameCategory && aIsSameTag) {
          aPriority = 1;
        } else if (aIsSameTag) {
          aPriority = 2;
        } else if (aIsSameCategory) {
          aPriority = 3;
        }

        if (bIsSameCategory && bIsSameTag) {
          bPriority = 1;
        } else if (bIsSameTag) {
          bPriority = 2;
        } else if (bIsSameCategory) {
          bPriority = 3;
        }

        if (aPriority < bPriority) {
          return -1;
        } else if (aPriority > bPriority) {
          return 1;
        } else {
          return 0;
        }
      });
      if (recommenedStoryList.length < 4) {
        List<String> excludeStoryIds = [];
        excludeStoryIds.add(id);
        for (StoryListItem item in recommenedStoryList) {
          excludeStoryIds.add(item.id);
        }
        StoryListItemList latestStoryList = await fetchLatestStoryList(
            excludeStoryIds, 4 - recommenedStoryList.length);
        recommenedStoryList.addAll(latestStoryList);
      }
    } else {
      recommenedStoryList = await fetchLatestStoryList([], 4);
    }
    return recommenedStoryList;
  }

  @override
  bool hasSameCategories(
      StoryListItem storyListItem, List<String> categoriesSlug) {
    if (storyListItem.categoryList != null &&
        storyListItem.categoryList!.isNotEmpty) {
      for (String categorySlug in categoriesSlug) {
        if (storyListItem.categoryList!
            .every((element) => element.slug == categorySlug)) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  bool hasSameTags(StoryListItem storyListItem, List<String> tagsName) {
    if (storyListItem.tags != null && storyListItem.tags!.isNotEmpty) {
      for (String tagSlug in tagsName) {
        if (storyListItem.tags!.every((element) => element.slug == tagSlug)) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  Future<StoryListItemList> fetchLatestStoryList(
      List<String> idList, int first) async {
    const key = 'fetchLatestStoryList';

    const String query = """
    query (
      \$where: PostWhereInput,
      \$first: Int,
    ) {
      allPosts(
        where: \$where,
        first: \$first, 
        sortBy: [ publishTime_DESC ]
      ) {
        id
        slug
        name
        publishTime
        style
        wordCount
        heroImage {
          urlMobileSized
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"id_not_in": idList, "state": "published"},
      "first": first
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: newsStoryCacheDuration,
        headers: {"Content-Type": "application/json"});

    StoryListItemList latestStoryList =
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);

    return latestStoryList;
  }
}
