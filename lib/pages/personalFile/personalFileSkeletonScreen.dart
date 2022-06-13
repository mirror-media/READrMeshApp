import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class PersonalFileSkeletonScreen extends StatelessWidget {
  const PersonalFileSkeletonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          CupertinoIcons.person_crop_circle_fill,
          color: Color.fromRGBO(224, 224, 224, 1),
          size: 80,
        ),
        const SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
          highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              height: 24,
              width: 120,
              color: Colors.white,
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
                child: _rowItem(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 20,
              child: const VerticalDivider(
                color: readrBlack10,
                thickness: 0.5,
              ),
            ),
            _rowItem(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 20,
              child: const VerticalDivider(
                color: readrBlack10,
                thickness: 0.5,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _rowItem(),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _rowItem() {
    return Column(
      children: [
        const Text(
          '0',
          style: TextStyle(
            color: readrBlack87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
          highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              height: 12,
              width: 60,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
