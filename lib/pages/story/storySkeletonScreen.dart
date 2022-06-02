import 'package:flutter/material.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:shimmer/shimmer.dart';

class StorySkeletonScreen extends StatelessWidget {
  final String newsId;
  const StorySkeletonScreen(this.newsId);

  @override
  Widget build(BuildContext context) {
    double widthWithPadding = MediaQuery.of(context).size.width - 40;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          StoryAppBar(newsId),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                  highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                  child: Container(
                    height: 187.5,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                      highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Shimmer.fromColors(
                      baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                      highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: widthWithPadding * 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                _lineItem(widthWithPadding * 0.8),
                _lineItem(widthWithPadding * 0.6),
                _lineItem(widthWithPadding * 0.6),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _lineItem(double lastLineWidth) {
    return Shimmer.fromColors(
      baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
      highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                height: 12,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                height: 12,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                height: 12,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                height: 12,
                color: Colors.white,
                width: lastLineWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
