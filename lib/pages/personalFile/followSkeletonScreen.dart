import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';
import 'package:shimmer/shimmer.dart';

class FollowSkeletonScreen extends StatelessWidget {
  const FollowSkeletonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) => _listItem(context),
        separatorBuilder: (context, index) => Divider(
          color: Theme.of(context).extension<CustomColors>()!.primary300!,
          height: 1,
        ),
        itemCount: 3,
      ),
    );
  }

  Widget _listItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor:
                Theme.of(context).extension<CustomColors>()!.shimmerBaseColor!,
            highlightColor:
                Theme.of(context).extension<CustomColors>()!.primary200!,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                height: 44,
                width: 44,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Theme.of(context)
                    .extension<CustomColors>()!
                    .shimmerBaseColor!,
                highlightColor:
                    Theme.of(context).extension<CustomColors>()!.primary200!,
                child: Container(
                  height: 12,
                  width: 120,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: Theme.of(context)
                    .extension<CustomColors>()!
                    .shimmerBaseColor!,
                highlightColor:
                    Theme.of(context).extension<CustomColors>()!.primary200!,
                child: Container(
                  height: 12,
                  width: 40,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
