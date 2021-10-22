import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/error/mNewsErrorWidget.dart';

class Error500Widget extends StatelessWidget {
  final bool isNoButton;
  final bool isColumn;
  const Error500Widget({
    this.isNoButton = false,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    // if (isNoButton) {
    //   return MNewsNoButtonErrorWidget(
    //     assetImagePath: error500Png,
    //     title: '抱歉...訊號出了點問題',
    //     isColumn: isColumn,
    //   );
    // }

    return MNewsErrorWidget(
      assetImagePath: error500Png,
      title: '抱歉...訊號出了點問題',
      buttonName: '回首頁',
      onPressed: () => Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
      isColumn: isColumn,
    );
  }
}
