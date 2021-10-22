import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';

class InitLoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColor,
      body: Center(
        child: Image.asset(logoPng, scale: 4.0),
      ),
    );
  }
}
