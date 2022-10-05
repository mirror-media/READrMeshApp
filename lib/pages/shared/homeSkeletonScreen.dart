import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color baseColor = Theme.of(context).brightness == Brightness.light
        ? meshBlack10.withOpacity(0.15)
        : meshGray20.withOpacity(0.25);
    Color highlightColor = Theme.of(context).brightness == Brightness.light
        ? meshBlack10
        : meshGray20;
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0),
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(
        height: 8,
        width: double.infinity,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    height: 12,
                    color: Theme.of(context).backgroundColor,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: double.infinity,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          color: Theme.of(context).backgroundColor,
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
