import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/models/story.dart';

abstract class StoryRepos {
  Future<Story> fetchPublishedStoryById(String id);
}

class StoryServices implements StoryRepos {
  @override
  Future<Story> fetchPublishedStoryById(String id) async {
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

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.readr,
      queryBody: query,
      variables: variables,
      cacheDuration: 30.minutes,
    );

    return Story.fromJson(jsonResponse.data!['allPosts'][0]);
  }
}
