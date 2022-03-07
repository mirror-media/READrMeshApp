import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final MemberService _memberService = MemberService();

  login(bool isNewUser) async {
    emit(Loading());
    try {
      if (!isNewUser) {
        var result = await _memberService.fetchMemberData();
        if (result != null) {
          await UserHelper.instance.fetchUserData();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstTime', false);
          emit(ExistingMemberLogin());
        } else {
          emit(NewMemberSignup(await _fetchPublisherTitles()));
        }
      } else {
        emit(NewMemberSignup(await _fetchPublisherTitles()));
      }
    } catch (e) {
      print('Login Error:' + e.toString());
      emit(LoginError());
    }
  }

  Future<List<String>> _fetchPublisherTitles() async {
    var publisherList = await PersonalFileService().fetchAllPublishers();
    List<String> publisherTitleList = [];
    for (var publisher in publisherList) {
      publisherTitleList.add(publisher.title);
    }
    return publisherTitleList;
  }
}