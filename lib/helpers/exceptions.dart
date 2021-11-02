import 'package:flutter/material.dart';
import 'package:readr/pages/errorPage.dart';

abstract class MNewException {
  dynamic message;
  MNewException(this.message);

  Widget renderWidget({
    required void Function() onPressed,
  });
}

class Error500Exception implements MNewException {
  @override
  dynamic message;
  Error500Exception(this.message);

  @override
  Widget renderWidget({
    required void Function() onPressed,
  }) =>
      ErrorPage(error: this, onPressed: onPressed);
}

class Error400Exception implements MNewException {
  @override
  dynamic message;
  Error400Exception(this.message);

  @override
  Widget renderWidget({
    required void Function() onPressed,
  }) =>
      ErrorPage(error: this, onPressed: onPressed);
}

class NoInternetException implements MNewException {
  @override
  dynamic message;
  NoInternetException(this.message);

  @override
  Widget renderWidget({
    required void Function() onPressed,
  }) =>
      ErrorPage(error: this, onPressed: onPressed);
}

class NoServiceFoundException extends Error500Exception {
  NoServiceFoundException(message) : super(message);
}

class InvalidFormatException extends Error400Exception {
  InvalidFormatException(message) : super(message);
}

class UnknownException extends Error400Exception {
  UnknownException(message) : super(message);
}
