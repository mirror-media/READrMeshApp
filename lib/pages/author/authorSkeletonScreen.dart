import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shimmer/shimmer.dart';

class AuthorSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: appBarColor,
      ),
      body: Container(
        color: const Color.fromRGBO(246, 246, 251, 1),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, top: 0, bottom: 24),
                color: Colors.white,
                child: Row(
                  children: [
                    Image.asset(
                      authorDefaultPng,
                      width: 78,
                      height: 78,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                      highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 20,
                          width: 157,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                child: Shimmer.fromColors(
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
                        padding: const EdgeInsets.symmetric(vertical: 6),
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
                        padding: const EdgeInsets.symmetric(vertical: 6),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
