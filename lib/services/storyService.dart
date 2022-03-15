import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/story.dart';

class StoryServices {
  final ApiBaseHelper _helper = ApiBaseHelper();

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
        readingTime
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
          bio
          image{
            urlMobileSized
          }
        }
        photographers {
          name
          slug
          bio
          image{
            urlMobileSized
          }
        }
        cameraOperators {
          name
          slug
          bio
          image{
            urlMobileSized
          }
        }
        designers {
          name
          slug
          bio
          image{
            urlMobileSized
          }
        }
        engineers {
          name 
          slug
          bio
          image{
            urlMobileSized
          }
        }
        dataAnalysts{
          name
          slug
          bio
          image{
            urlMobileSized
          }
        }
        otherByline
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
        key, Environment().config.readrApi, jsonEncode(graphqlBody.toJson()),
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
