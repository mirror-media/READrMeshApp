import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/content.dart';
import 'package:readr/pages/story/widgets/imageViewerWidget.dart';

class ImageAndDescriptionSlideShowWidget extends StatefulWidget {
  final List<Content> contentList;
  final double textSize;
  final List<String> imageUrlList;
  const ImageAndDescriptionSlideShowWidget({
    required this.contentList,
    this.textSize = 20,
    required this.imageUrlList,
  });

  @override
  State<ImageAndDescriptionSlideShowWidget> createState() =>
      _ImageAndDescriptionSlideShowWidgetState();
}

class _ImageAndDescriptionSlideShowWidgetState
    extends State<ImageAndDescriptionSlideShowWidget> {
  late List<Content> contentList;
  late double textSize;

  @override
  void initState() {
    contentList = widget.contentList;
    textSize = widget.textSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    double imageHeight = width / 16 * 9;

    List<Widget> imageSilders = contentList
        .map(
          (content) => GestureDetector(
            onTap: () {
              Get.to(() => ImageViewerWidget(
                    imageUrlList: widget.imageUrlList,
                    openImageUrl: content.data,
                  ));
            },
            child: Column(
              children: [
                CachedNetworkImage(
                  height: imageHeight,
                  width: width,
                  imageUrl: content.data,
                  placeholder: (context, url) => Container(
                    height: imageHeight,
                    width: width,
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: imageHeight,
                    width: width,
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                  fit: BoxFit.fitHeight,
                ),
                const SizedBox(
                  height: 8,
                ),
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary500,
                        fontSize: textSize - 4,
                        fontWeight: FontWeight.w400),
                    text: content.description,
                  ),
                ),
                SizedBox(
                  height: _isNullOrEmpty(content.description) ? 12 : 32,
                ),
              ],
            ),
          ),
        )
        .toList();

    return Column(
      children: imageSilders,
    );
  }

  bool _isNullOrEmpty(String? text) {
    if (text == null || text == "" || text == " " || text.isEmpty) {
      return true;
    }
    return false;
  }
}
