import 'package:flutter/material.dart';

class MNewsNoButtonErrorWidget extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final bool isColumn;
  const MNewsNoButtonErrorWidget({
    required this.assetImagePath,
    required this.title,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (isColumn) {
      return Column(
        children: [
          SizedBox(height: height / 6),
          Center(child: Image.asset(assetImagePath)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xff757575),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      );
    }
    return ListView(
      children: [
        SizedBox(height: height / 3),
        Center(child: Image.asset(assetImagePath)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xff757575),
            ),
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}
