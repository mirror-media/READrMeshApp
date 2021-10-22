import 'dart:core';

import 'package:flutter/material.dart';

class StoryBriefTopFrameClipper extends CustomClipper<Path> {
  final double borderWidth;
  StoryBriefTopFrameClipper({this.borderWidth = 3.0});

  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(0 + borderWidth, height)
      ..lineTo(0 + borderWidth, borderWidth)
      ..lineTo(width - borderWidth, borderWidth)
      ..lineTo(width - borderWidth, height)
      ..lineTo(width, height)
      ..lineTo(width, 0)
      ..lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class StoryBriefBottomFrameClipper extends CustomClipper<Path> {
  final double borderWidth;
  StoryBriefBottomFrameClipper({this.borderWidth = 3.0});

  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..lineTo(width, 0)
      ..lineTo(width - borderWidth, 0)
      ..lineTo(width - borderWidth, height - borderWidth)
      ..lineTo(borderWidth, height - borderWidth)
      ..lineTo(borderWidth, 0)
      ..lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
