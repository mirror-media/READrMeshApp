import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/error/mNewsErrorWidget.dart';

class Error400Widget extends StatelessWidget {
  final bool isNoButton;
  final bool isColumn;
  const Error400Widget({
    this.isNoButton = false,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    // if (isNoButton) {
    //   return MNewsNoButtonErrorWidget(
    //     assetImagePath: error400Png,
    //     title: '抱歉...訊號出了點問題',
    //     isColumn: isColumn,
    //   );
    // }

    return MNewsErrorWidget(
      assetImagePath: error400Png,
      title: '這個頁面失去訊號了...',
      buttonName: '回首頁',
      onPressed: () => Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
      isColumn: isColumn,
    );
  }
}
