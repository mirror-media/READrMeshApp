import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0),
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(
        height: 8,
        width: double.infinity,
        child: Container(
          color: homeScreenBackgroundColor,
        ),
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
