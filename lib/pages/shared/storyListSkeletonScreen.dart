import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoryListSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
            highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      height: 90,
                      width: 90,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          width: double.infinity,
                        ),
                        Container(
                          height: 20,
                          color: Colors.white,
                          width:
                              (MediaQuery.of(context).size.width - 40) * 0.52,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
