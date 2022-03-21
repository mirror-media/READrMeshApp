import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class FollowSkeletonScreen extends StatelessWidget {
  const FollowSkeletonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) => _listItem(),
        separatorBuilder: (context, index) => const Divider(
          color: readrBlack20,
          height: 1,
        ),
        itemCount: 3,
      ),
    );
  }

  Widget _listItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
            highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                height: 44,
                width: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  height: 12,
                  width: 120,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  height: 12,
                  width: 40,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
