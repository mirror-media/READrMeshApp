import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final EditorChoiceItem editorChoiceItem;
  final double width;
  const CarouselDisplayWidget({
    required this.editorChoiceItem,
    required this.width,
  });

  final double aspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Stack(
            children: [
              _displayImage(width, editorChoiceItem),
              Align(
                alignment: Alignment.topLeft,
                child: _displayTag(),
              ),
            ],
          ),
          Expanded(child: _displayTitle(editorChoiceItem)),
        ],
      ),
      onTap: () {
        if (editorChoiceItem.id != null) {
          AutoRouter.of(context).push(StoryRoute(id: editorChoiceItem.id!));
        }
      },
    );
  }

  Widget _displayImage(double width, EditorChoiceItem editorChoiceItem) {
    return editorChoiceItem.photoUrl == null
        ? SvgPicture.asset(defaultImageSvg)
        : CachedNetworkImage(
            height: width / aspectRatio,
            width: width,
            imageUrl: editorChoiceItem.photoUrl!,
            placeholder: (context, url) => Container(
              height: width / aspectRatio,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / aspectRatio,
              width: width,
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          );
  }

  Widget _displayTag() {
    return Container(
      decoration: const BoxDecoration(
        color: editorChoiceTagColor,
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Text(
          '編輯精選',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _displayTitle(EditorChoiceItem editorChoiceItem) {
    return Container(
      color: editorChoiceTitleBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
              text: editorChoiceItem.name,
            ),
          ),
        ),
      ),
    );
  }
}
