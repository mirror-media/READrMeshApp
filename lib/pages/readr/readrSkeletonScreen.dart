import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class ReadrSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        leading: Container(
          padding: const EdgeInsets.only(top: 8, left: 8),
          margin: const EdgeInsets.all(11),
          child: SvgPicture.asset(
            logoSimplifySvg,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Container(
                height: 300,
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
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
          if (index == 2) {
            return Container(
              height: 4,
              width: double.infinity,
              color: const Color.fromRGBO(246, 246, 251, 1),
            );
          }
          if (index == 3) {
            return Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    20, 24, MediaQuery.of(context).size.width - 110, 0),
                height: 20,
                color: Colors.white,
              ),
            );
          }

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
