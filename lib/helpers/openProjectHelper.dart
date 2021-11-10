import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/storyListItem.dart';

class OpenProjectHelper {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

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
    await browser.open(
      url: Uri.parse(projectUrl),
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(),
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  phaseByEditorChoiceItem(EditorChoiceItem editorChoiceItem) async {
    String projectUrl;
    if (editorChoiceItem.link != null) {
      projectUrl = editorChoiceItem.link!;
    } else {
      switch (editorChoiceItem.style) {
        case 'embedded':
          projectUrl = readrProjectLink + 'post/${editorChoiceItem.id}';
          break;
        case 'report':
          projectUrl = readrProjectLink + '/project/${editorChoiceItem.slug}';
          break;
        case 'project3':
          projectUrl = readrProjectLink + '/project/3/${editorChoiceItem.slug}';
          break;
        default:
          projectUrl = readrProjectLink;
      }
    }
    await browser.open(
      url: Uri.parse(projectUrl),
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(),
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }

  openByUrl(String url) async {
    await browser.open(
      url: Uri.parse(url),
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(),
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }
}
