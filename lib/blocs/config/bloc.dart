import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/blocs/config/states.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/services/configService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  ConfigBloc() : super(ConfigInitState());
  final ConfigServices configRepos = ConfigServices();

  @override
  Stream<ConfigState> mapEventToState(ConfigEvents event) async* {
    print(event.toString());
    try {
      yield ConfigLoading();
      if (event is LoadingConfig) {
        DynamicLinkHelper().initDynamicLinks(event.context);
        bool isSuccess = await configRepos.loadTheConfig(event.context);
        FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
        remoteConfig
            .setDefaults(<String, dynamic>{'min_version_number': '0.0.1'});
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 1),
        ));
        await remoteConfig.fetchAndActivate();
        String minAppVersion = remoteConfig.getString('min_version_number');
        final prefs = await SharedPreferences.getInstance();
        bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
        if (isFirstTime) {
          yield Onboarding();
        } else {
          await UserHelper.instance.fetchUserData();
          yield ConfigLoaded(
            isSuccess: isSuccess,
            minAppVersion: minAppVersion,
          );
        }
      } else {
        await UserHelper.instance.fetchUserData();
        yield LoginStateUpdate();
      }
    } catch (e) {
      yield ConfigError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
