import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';

class TabContentNoResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            tabNoContentPng,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 12),
          const Text(
            '這個分類目前沒有文章',
            style:
                TextStyle(color: Color.fromRGBO(0, 9, 40, 0.3), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
