import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/personalFileService.dart';

part 'personalFile_state.dart';

class PersonalFileCubit extends Cubit<PersonalFileState> {
  final PersonalFileRepos personalFileRepos;
  PersonalFileCubit({required this.personalFileRepos})
      : super(PersonalFileInitial());

  fetchMemberData(
    Member viewMember, {
    bool isReload = false,
  }) async {
    if (isReload) {
      emit(PersonalFileReloading());
    } else {
      emit(PersonalFileLoading());
    }

    late Member viewMemberData;
    await Future.wait([
      personalFileRepos
          .fetchMemberData(viewMember)
          .then((value) => viewMemberData = value),
      Get.find<UserService>().fetchUserData(),
    ]);

    emit(PersonalFileLoaded(viewMemberData));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    emit(PersonalFileError(error: determineException(error)));
    super.onError(error, stackTrace);
  }
}
