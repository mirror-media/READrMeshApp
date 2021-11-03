import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StorySkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
            highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
            child: Container(
              height: 196.88,
              width: double.infinity,
              color: Colors.white,
            ),
          );
        }
        if (index == 1) {
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
            highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 32,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    width: double.infinity,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 32,
                      width: (MediaQuery.of(context).size.width - 40) * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        double lastLineWidth = MediaQuery.of(context).size.width - 40;
        if (index == 2) {
          lastLineWidth = lastLineWidth * 0.8;
        } else if (index == 3) {
          lastLineWidth = lastLineWidth * 0.4;
        } else if (index == 4) {
          lastLineWidth = lastLineWidth * 0.6;
        }

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
      },
    );
  }
}
