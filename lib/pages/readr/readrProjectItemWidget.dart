import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:shimmer/shimmer.dart';

class ReadrProjectItemWidget extends StatelessWidget {
  final NewsListItem projectItem;
  const ReadrProjectItemWidget(this.projectItem, {Key? key}) : super(key: key);

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
          placeholder: (context, url) => SizedBox(
            width: width,
            height: height,
            child: Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(),
          imageBuilder: (context, imageProvider) {
            return Image(
              image: imageProvider,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
            );
          },
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
            NewsInfo(projectItem, key: key),
            const SizedBox(height: 18),
            PickBar(projectItem.controllerTag),
          ],
        ),
        onTap: () async {
          Get.to(
            () => StoryPage(
              news: projectItem,
            ),
            fullscreenDialog: true,
          );
        });
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      child: ExtendedText(
        projectItem.title,
        joinZeroWidthSpace: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: readrBlack87,
          fontSize: 20.0,
          fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
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
