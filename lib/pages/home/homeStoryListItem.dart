import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/storyListItem.dart';

class HomeStoryListItem extends StatelessWidget {
  final StoryListItem storyListItem;
  const HomeStoryListItem({required this.storyListItem});

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (storyListItem.photoUrl != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(
          width: 90,
          height: 90,
          imageUrl: storyListItem.photoUrl!,
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
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: SizedBox(
          width: 90,
          height: 90,
          child: SvgPicture.asset(defaultImageSvg, fit: BoxFit.cover),
        ),
      );
    }
    return InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          height: 1.5,
                        ),
                        text: storyListItem.name,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    _displayTimeAndReadingTime(),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          AutoRouter.of(context).push(StoryRoute(id: storyListItem.id));
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
          Text(DateFormat('MM/dd').format(storyListItem.publishTime),
              style: style),
          if (storyListItem.readingTime != null &&
              storyListItem.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${storyListItem.readingTime!.toString()} 分鐘',
              style: style,
            ),
        ],
      ),
    );
  }
}
