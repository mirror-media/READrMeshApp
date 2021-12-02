import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TagListSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(246, 246, 251, 1),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      height: 175.88,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 20,
                      width: (MediaQuery.of(context).size.width - 40) * 0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
