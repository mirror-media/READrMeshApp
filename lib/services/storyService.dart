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
      posts(
        where: \$where
      ) {
        style
        name
        readingTime
        summaryApiData
        apiData
        citationApiData
        publishTime
        updatedAt
        heroImage {
          resized {
            w480
            w1200
          }
        }
        heroVideo {
          coverPhoto {
            resized {
              original
              w480
              w800
              w1200
              w1600
              w2400
            }
          }
          file {
            url
          }
          url
        }
        heroCaption
        categories {
          id
          slug
          title
        }
        writers {
          name
          id
          bio
          image{
            resized {
              w480
            }
          }
        }
        photographers {
          name
          id
          bio
          image{
            resized {
              w480
            }
          }
        }
        cameraOperators {
          name
          id
          bio
          image{
            resized {
              w480
            }
          }
        }
        designers {
          name
          id
          bio
          image{
            resized {
              w480
            }
          }
        }
        engineers {
          name 
          id
          bio
          image{
            resized {
              w480
            }          }
        }
        dataAnalysts{
          name
          id
          bio
          image{
            resized {
              w480
            }          }
        }
        otherByline
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "id": {"equals": id}
      },
    };

    final jsonResponse = await Get.find<GraphQLService>().query(
      api: Api.readr,
      queryBody: query,
      variables: variables,
      cacheDuration: 30.minutes,
    );

    return Story.fromJson(jsonResponse.data!['posts'][0]);
  }
}
