import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenProjectHelper {
  phaseByStoryListItem(StoryListItem projectListItem) async {
    String projectUrl;
    switch (projectListItem.style) {
      case 'embedded':
        projectUrl = readrProjectLink + 'post/${projectListItem.id}';
        break;
      case 'report':
        projectUrl = readrProjectLink + 'project/${projectListItem.slug}';
        break;
      case 'project3':
        projectUrl = readrProjectLink + 'project/3/${projectListItem.slug}';
        break;
      default:
        projectUrl = readrProjectLink;
    }
    await launch(projectUrl);
  }

  openByUrl(String url) async {
    await launch(url);
  }
}
