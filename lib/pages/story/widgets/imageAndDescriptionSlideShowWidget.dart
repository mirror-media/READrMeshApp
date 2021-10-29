import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/contentList.dart';

class ImageAndDescriptionSlideShowWidget extends StatefulWidget {
  final ContentList contentList;
  final double textSize;
  const ImageAndDescriptionSlideShowWidget(
      {required this.contentList, this.textSize = 20});

  @override
  _ImageAndDescriptionSlideShowWidgetState createState() =>
      _ImageAndDescriptionSlideShowWidgetState();
}

class _ImageAndDescriptionSlideShowWidgetState
    extends State<ImageAndDescriptionSlideShowWidget> {
  int currentPage = 1;
  late ContentList contentList;
  late CarouselOptions options;
  CarouselController imageCarouselController = CarouselController();
  CarouselController textCarouselController = CarouselController();
  late double textSize;

  Widget backArrowWidget = const Icon(
    Icons.arrow_back_ios,
    color: slideShowColor,
    size: 30,
  );

  Widget forwardArrowWidget = const Icon(
    Icons.arrow_forward_ios,
    color: slideShowColor,
    size: 30,
  );

  // VerticalDivider is broken? so use Container
  Widget myVerticalDivider = Padding(
    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
    child: Container(
      color: const Color(0xff757575),
      width: 1.8,
      height: 20,
    ),
  );

  @override
  void initState() {
    contentList = widget.contentList;
    textSize = widget.textSize;
    super.initState();
  }

  @override
  void didUpdateWidget(ImageAndDescriptionSlideShowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    textSize = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 48;
    double imageHeight = width / 16 * 9;
    options = CarouselOptions(
      viewportFraction: 1,
      aspectRatio: 16 / 9,
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {
        setState(() {
          currentPage = index + 1;
        });
      },
    );

    List<Widget> imageSilders = contentList
        .map(
          (content) => CachedNetworkImage(
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
        )
        .toList();

    return Column(
      children: [
        CarouselSlider(
          items: imageSilders,
          carouselController: imageCarouselController,
          options: options,
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            child: backArrowWidget,
            onTap: () {
              imageCarouselController.previousPage();
              textCarouselController.nextPage();
            },
          ),
          Row(
            children: [
              Text(
                currentPage.toString(),
                style: TextStyle(
                  color: slideShowColor,
                  fontSize: textSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              myVerticalDivider,
              Text(
                imageSilders.length.toString(),
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          InkWell(
            child: forwardArrowWidget,
            onTap: () {
              imageCarouselController.nextPage();
              textCarouselController.nextPage();
            },
          ),
        ]),
        const SizedBox(height: 18),
        _buildTextCarouselSlider(textCarouselController),
      ],
    );
  }

  Widget _buildTextCarouselSlider(CarouselController carouselController) {
    CarouselOptions options = CarouselOptions(
      height: 38,
      viewportFraction: 1,
      //aspectRatio: 16/9,
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
    );
    List<Widget> textSilders = contentList
        .map(
          (content) => RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            text: TextSpan(
              style: TextStyle(
                  color: const Color(0xff757575),
                  fontSize: textSize - 5,
                  fontWeight: FontWeight.w400),
              text: content.description,
            ),
          ),
        )
        .toList();

    return CarouselSlider(
      items: textSilders,
      carouselController: carouselController,
      options: options,
    );
  }
}
