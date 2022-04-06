import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/userHelper.dart';
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
      UserHelper.instance.fetchUserData(),
    ]);

    emit(PersonalFileLoaded(viewMemberData));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    emit(PersonalFileError(error: determineException(error)));
    super.onError(error, stackTrace);
  }
}
