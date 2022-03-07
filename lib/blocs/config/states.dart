abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  final String minAppVersion;
  ConfigLoaded({
    required this.isSuccess,
    required this.minAppVersion,
  });
}

class ConfigError extends ConfigState {
  final dynamic error;
  ConfigError({this.error});
}

class Onboarding extends ConfigState {}
