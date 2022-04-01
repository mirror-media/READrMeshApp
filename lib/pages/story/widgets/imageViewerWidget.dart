import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerWidget extends StatefulWidget {
  final List<String> imageUrlList;
  final String openImageUrl;
  const ImageViewerWidget({
    required this.imageUrlList,
    required this.openImageUrl,
  });

  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  int nowIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    int openIndex = widget.imageUrlList
        .indexWhere((element) => element == widget.openImageUrl);
    if (openIndex != -1) {
      nowIndex = openIndex;
    }

    _controller = PageController(initialPage: nowIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          '${nowIndex + 1}/${widget.imageUrlList.length}',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PhotoViewGallery.builder(
          itemCount: widget.imageUrlList.length,
          pageController: _controller,
          onPageChanged: (index) {
            setState(() {
              nowIndex = index;
            });
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.imageUrlList[index]),
              basePosition: Alignment.center,
              heroAttributes: PhotoViewHeroAttributes(
                tag: widget.imageUrlList[index],
                transitionOnUserGestures: true,
              ),
              minScale: PhotoViewComputedScale.contained,
            );
          },
          loadingBuilder: (context, progress) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator.adaptive(
                value: progress == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
              ),
            ),
          ),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
