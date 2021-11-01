import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/storyListItem.dart';

class HomeStoryPjojectItem extends StatelessWidget {
  final StoryListItem projectListItem;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  HomeStoryPjojectItem({required this.projectListItem});

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (projectListItem.photoUrl != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(
          imageUrl: projectListItem.photoUrl!,
          placeholder: (context, url) => Container(
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.cover,
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width - 40;
      double height = width * 9 / 16;
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: SizedBox(
          width: width,
          height: height,
          child: SvgPicture.asset(defaultImageSvg, fit: BoxFit.cover),
        ),
      );
    }
    return InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 12.0),
                child: Stack(
                  children: [
                    image,
                    Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 12,
                      ),
                      child: _displayTag(),
                    ),
                  ],
                ),
              ),
              Container(
                color: hightLightColor,
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            height: 1.5,
                          ),
                          text: projectListItem.name,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _displayTimeAndReadingTime(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          String projectUrl;
          switch (projectListItem.style) {
            case 'embedded':
              projectUrl = readrProjectLink + 'post/${projectListItem.id}';
              break;
            case 'report':
              projectUrl =
                  readrProjectLink + '/project/${projectListItem.slug}';
              break;
            case 'project3':
              projectUrl =
                  readrProjectLink + '/project/3/${projectListItem.slug}';
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
        });
  }

  Widget _displayTimeAndReadingTime() {
    TextStyle style = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.only(top: 4),
      color: editorChoiceBackgroundColor,
      child: Row(
        children: [
          Text(DateFormat('MM/dd').format(projectListItem.publishTime),
              style: style),
          if (projectListItem.readingTime != null &&
              projectListItem.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${projectListItem.readingTime!.round().toString()} 分鐘',
              style: style,
            ),
        ],
      ),
    );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
        borderRadius: BorderRadiusDirectional.circular(2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          '專題',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
