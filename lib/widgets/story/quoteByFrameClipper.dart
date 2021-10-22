import 'package:flutter/material.dart';

class QuoteByTopFrameClipper extends CustomClipper<Path> {
  final double borderWidth;
  QuoteByTopFrameClipper({this.borderWidth = 3.0});

  @override
  Path getClip(Size size) {
    Rect topLeftTop = Rect.fromLTRB(0, 0, size.height, borderWidth);
    Rect topLeftLeft = Rect.fromLTRB(0, 0, borderWidth, size.height);

    Path path = Path()..addRect(topLeftTop)..addRect(topLeftLeft);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class QuoteByBottomFrameClipper extends CustomClipper<Path> {
  final double borderWidth;
  QuoteByBottomFrameClipper({this.borderWidth = 3.0});

  @override
  Path getClip(Size size) {
    Rect bottomRightBottom = Rect.fromLTRB(size.width - size.height,
        size.height - borderWidth, size.width, size.height);
    Rect bottomRightRight =
        Rect.fromLTRB(size.width - borderWidth, 0, size.width, size.height);

    Path path = Path()..addRect(bottomRightBottom)..addRect(bottomRightRight);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
