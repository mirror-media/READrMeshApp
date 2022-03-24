import 'package:flutter/material.dart';

abstract class ConfigEvents {
  ConfigEvents();
}

class LoadingConfig implements ConfigEvents {
  final BuildContext context;
  LoadingConfig(this.context);

  @override
  String toString() => 'LoadingConfig';
}

class LoginUpdate implements ConfigEvents {
  @override
  String toString() => 'LoginUpdate';
}
