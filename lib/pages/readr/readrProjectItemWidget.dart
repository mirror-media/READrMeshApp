import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';

class ReadrProjectItemWidget extends StatelessWidget {
  final NewsListItem projectItem;
  const ReadrProjectItemWidget(this.projectItem);

  @override
  Widget build(BuildContext context) {
    Widget image;
    double width = MediaQuery.of(context).size.width - 40;
    double height = width / 2;
    if (projectItem.heroImageUrl != null &&
        projectItem.heroImageUrl!.isNotEmpty) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(
          imageUrl: projectItem.heroImageUrl!,
          placeholder: (context, url) => Container(
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.cover,
          width: width,
          height: height,
        ),
      );
    } else {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
            _displayTitle(),
            const SizedBox(height: 8),
            NewsInfo(projectItem),
            const SizedBox(height: 18),
            PickBar(NewsListItemPick(projectItem)),
          ],
        ),
        onTap: () async {
          AutoRouter.of(context).push(NewsStoryRoute(
            news: projectItem,
          ));
        });
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      child: Text(
        projectItem.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: const TextStyle(
          color: readrBlack87,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
        borderRadius: BorderRadiusDirectional.circular(6),
      ),
      height: 24,
      width: 40,
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Text(
          '專題',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
