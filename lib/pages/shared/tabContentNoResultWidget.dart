import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class TabContentNoResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            tabNoContentPng,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 12),
          Text(
            'tabContentNoResult'.tr,
            style:
                Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
