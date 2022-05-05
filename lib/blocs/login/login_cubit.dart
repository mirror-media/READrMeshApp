import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final MemberRepos memberRepos;
  final PersonalFileRepos personalFileRepos;
  LoginCubit({required this.memberRepos, required this.personalFileRepos})
      : super(LoginInitial());

  login(bool isNewUser) async {
    emit(Loading());
    try {
      var result = await memberRepos.fetchMemberData();
      if (result != null) {
        await Get.find<UserService>().fetchUserData(member: result);
        final prefs = await SharedPreferences.getInstance();
        final List<String> followingPublisherIds =
            prefs.getStringList('followingPublisherIds') ?? [];
        if (followingPublisherIds.isNotEmpty) {
          await Get.find<UserService>()
              .addVisitorFollowing(followingPublisherIds);
        }

        final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
        if (isFirstTime) {
          await prefs.setBool('isFirstTime', false);
        }

        final String invitationCodeId =
            prefs.getString('invitationCodeId') ?? '';
        if (invitationCodeId.isNotEmpty) {
          await InvitationCodeService().linkInvitationCode(invitationCodeId);
        }

        emit(ExistingMemberLogin());
      } else {
        emit(NewMemberSignup(await _fetchPublisherTitles()));
      }
    } catch (e) {
      print('Login Error:' + e.toString());
      emit(LoginError());
    }
  }

  Future<List<String>> _fetchPublisherTitles() async {
    var publisherList = await personalFileRepos.fetchAllPublishers();
    List<String> publisherTitleList = [];
    for (var publisher in publisherList) {
      publisherTitleList.add(publisher.title);
    }
    return publisherTitleList;
  }
}
