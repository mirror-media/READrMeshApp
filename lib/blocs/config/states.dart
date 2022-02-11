import 'package:readr/models/member.dart';

abstract class ConfigState {}

class ConfigInitState extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final bool isSuccess;
  final String minAppVersion;
  final Member currentUser;
  ConfigLoaded({
    required this.isSuccess,
    required this.minAppVersion,
    required this.currentUser,
  });
}

class ConfigError extends ConfigState {
  final dynamic error;
  ConfigError({this.error});
}
