import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/blocs/config/states.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/configService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class ConfigBloc extends Bloc<ConfigEvents, ConfigState> {
  final ConfigRepos configRepos;
  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  ConfigBloc({required this.configRepos}) : super(ConfigInitState());

  @override
  Stream<ConfigState> mapEventToState(ConfigEvents event) async* {
    print(event.toString());
    try {
      yield ConfigLoading();
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
      Member currentUser;
      if (FirebaseAuth.instance.currentUser != null) {
        // fetch user following members, categories, publishers, and member id
        currentUser = await _memberService.fetchMemberData();
      } else {
        currentUser = await _visitorService.fetchMemberData();
      }
      yield ConfigLoaded(
        isSuccess: isSuccess,
        minAppVersion: minAppVersion,
        currentUser: currentUser,
      );
    } catch (e) {
      yield ConfigError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
