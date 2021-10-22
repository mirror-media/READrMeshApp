import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/story.dart';

abstract class StoryRepos {
  Future<Story> fetchPublishedStoryBySlug(String slug);
}

class StoryServices implements StoryRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Story> fetchPublishedStoryBySlug(String slug) async {
    final key = 'fetchPublishedStoryBySlug?slug=$slug';

    const String query = """
    query (
      \$where: PostWhereInput,
    ) {
      allPosts(
        where: \$where
      ) {
        style
        name
        briefApiData
        contentApiData
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
        vocals {
          name
          slug
        }
        otherbyline
        tags {
          id
          name
        }
        relatedPosts {
          slug
          name
          heroImage {
            urlMobileSized
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"state": "published", "slug": slug},
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
    } catch (e) {
      throw FormatException(e.toString());
    }

    return story;
  }
}
