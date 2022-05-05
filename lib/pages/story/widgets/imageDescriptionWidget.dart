import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/pages/story/widgets/imageViewerWidget.dart';

class ImageDescriptionWidget extends StatelessWidget {
  final String imageUrl;
  final String? description;
  final double width;
  final double aspectRatio;
  final double textSize;
  final List<String> imageUrlList;
  const ImageDescriptionWidget({
    required this.imageUrl,
    required this.description,
    required this.width,
    this.aspectRatio = 16 / 9,
    this.textSize = 16,
    required this.imageUrlList,
  });

  @override
  Widget build(BuildContext context) {
    double height = width / aspectRatio;

    return GestureDetector(
      child: Wrap(
        //direction: Axis.vertical,
        children: [
          if (imageUrl != '')
            CachedNetworkImage(
              //height: imageHeight,
              width: width,
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(
                height: height,
                width: width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: height,
                width: width,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          if (description != null && description != '')
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
              child: Text(
                description!,
                style: TextStyle(fontSize: textSize, color: Colors.grey),
              ),
            ),
        ],
      ),
      onTap: () {
        Get.to(() => ImageViewerWidget(
              imageUrlList: imageUrlList,
              openImageUrl: imageUrl,
            ));
      },
    );
  }
}
