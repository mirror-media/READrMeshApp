import 'package:flutter/material.dart';

abstract class ConfigEvents {
  final BuildContext context;
  ConfigEvents(this.context);
}

class LoadingConfig implements ConfigEvents {
  @override
  final BuildContext context;
  LoadingConfig(this.context) : super();

  @override
  String toString() => 'LoadingConfig';
}
