import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:shimmer/shimmer.dart';

class StorySkeletonScreen extends StatelessWidget {
  final NewsListItem news;
  const StorySkeletonScreen(this.news);

  @override
  Widget build(BuildContext context) {
    double widthWithPadding = MediaQuery.of(context).size.width - 40;
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          StoryAppBar(news),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                      .extension<CustomColors>()!
                      .shimmerBaseColor!,
                  highlightColor:
                      Theme.of(context).extension<CustomColors>()!.primary100!,
                  child: Container(
                    height: 187.5,
                    width: double.infinity,
                    color: Theme.of(context).backgroundColor,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .shimmerBaseColor!,
                      highlightColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary100!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Shimmer.fromColors(
                      baseColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .shimmerBaseColor!,
                      highlightColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary100!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: widthWithPadding * 0.4,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
                _lineItem(context, widthWithPadding * 0.8),
                _lineItem(context, widthWithPadding * 0.6),
                _lineItem(context, widthWithPadding * 0.6),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _lineItem(BuildContext context, double lastLineWidth) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).extension<CustomColors>()!.shimmerBaseColor!,
      highlightColor: Theme.of(context).extension<CustomColors>()!.primary100!,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                height: 12,
                color: Theme.of(context).backgroundColor,
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
                color: Theme.of(context).backgroundColor,
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
                color: Theme.of(context).backgroundColor,
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
                color: Theme.of(context).backgroundColor,
                width: lastLineWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
