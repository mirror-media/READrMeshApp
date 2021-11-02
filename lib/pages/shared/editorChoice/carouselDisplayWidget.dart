import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final EditorChoiceItem editorChoiceItem;
  final double width;
  CarouselDisplayWidget({
    required this.editorChoiceItem,
    required this.width,
  });

  final double aspectRatio = 16 / 9;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.grey[100],
      child: Column(
        children: [
          const SizedBox(
            height: 16.0,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              color: Color(0xffEBF02C),
            ),
            child: Column(
              children: [
                _displayTitle(editorChoiceItem),
                _displaySummary(editorChoiceItem),
                _displayTimeAndReadingTime(editorChoiceItem),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        if (editorChoiceItem.isProject) {
          String projectUrl;
          if (editorChoiceItem.link != null) {
            projectUrl = editorChoiceItem.link!;
          } else {
            switch (editorChoiceItem.style) {
              case 'embedded':
                projectUrl = readrProjectLink + 'post/${editorChoiceItem.id}';
                break;
              case 'report':
                projectUrl =
                    readrProjectLink + '/project/${editorChoiceItem.slug}';
                break;
              case 'project3':
                projectUrl =
                    readrProjectLink + '/project/3/${editorChoiceItem.slug}';
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
        } else {
          if (editorChoiceItem.id != null) {
            AutoRouter.of(context).push(StoryRoute(id: editorChoiceItem.id!));
          } else if (editorChoiceItem.link != null) {
            await browser.open(
              url: Uri.parse(editorChoiceItem.link!),
              options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(),
                ios: IOSSafariOptions(barCollapsingEnabled: true),
              ),
            );
          }
        }
      },
    );
  }

  Widget _displayTitle(EditorChoiceItem editorChoiceItem) {
    return Container(
      color: editorChoiceBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
      alignment: Alignment.center,
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22.0,
          ),
          text: editorChoiceItem.name,
        ),
      ),
    );
  }

  Widget _displaySummary(EditorChoiceItem editorChoiceItem) {
    return editorChoiceItem.summary == null
        ? Container(
            color: editorChoiceBackgroundColor,
          )
        : Container(
            color: editorChoiceBackgroundColor,
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 0.0),
            alignment: Alignment.center,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                ),
                text: editorChoiceItem.summary!,
              ),
            ),
          );
  }

  Widget _displayTimeAndReadingTime(EditorChoiceItem editorChoiceItem) {
    TextStyle style = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 12),
      color: editorChoiceBackgroundColor,
      child: Row(
        children: [
          Text(editorChoiceItem.publishTimeString, style: style),
          if (editorChoiceItem.readingTime != null &&
              editorChoiceItem.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${editorChoiceItem.readingTime!.toString()} 分鐘',
              style: style,
            ),
        ],
      ),
    );
  }
}
