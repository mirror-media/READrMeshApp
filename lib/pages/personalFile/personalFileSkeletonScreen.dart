import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';
import 'package:shimmer/shimmer.dart';

class PersonalFileSkeletonScreen extends StatelessWidget {
  const PersonalFileSkeletonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          CupertinoIcons.person_crop_circle_fill,
          color: Theme.of(context).extension<CustomColors>()!.grayLight!,
          size: 80,
        ),
        const SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor:
              Theme.of(context).extension<CustomColors>()!.shimmerBaseColor!,
          highlightColor:
              Theme.of(context).extension<CustomColors>()!.primaryLv6!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              height: 24,
              width: 120,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _rowItem(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 20,
              child: const VerticalDivider(
                thickness: 0.5,
              ),
            ),
            _rowItem(context),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 20,
              child: const VerticalDivider(
                thickness: 0.5,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _rowItem(context),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _rowItem(BuildContext context) {
    return Column(
      children: [
        Text(
          '0',
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor:
              Theme.of(context).extension<CustomColors>()!.shimmerBaseColor!,
          highlightColor:
              Theme.of(context).extension<CustomColors>()!.primaryLv6!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              height: 12,
              width: 60,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}
