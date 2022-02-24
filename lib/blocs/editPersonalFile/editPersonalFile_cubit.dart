import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

part 'editPersonalFile_state.dart';

class EditPersonalFileCubit extends Cubit<EditPersonalFileState> {
  EditPersonalFileCubit() : super(EditPersonalFileInitial());
  final MemberService _memberService = MemberService();
  final PersonalFileService _personalFileService = PersonalFileService();

  loadPersonalFile() async {
    emit(EditPersonalFileLoading());
    try {
      emit(EditPersonalFileLoaded(await _memberService.fetchMemberData()));
    } catch (e) {
      emit(EditPersonalFileError(determineException(e)));
    }
  }

  savePersonalFile(Member member) async {
    emit(PersonalFileSaving());
    try {
      List<Publisher> _publisherList =
          await _personalFileService.fetchAllPublishers();
      bool checkResult = _validateNicknameAndId(_publisherList, member);
      if (!checkResult) {
        emit(PersonalFileNicknameError());
      } else {
        bool? result = await _memberService.updateMember(member);
        if (result == null) {
          emit(SavePersonalFileFailed());
        } else if (result) {
          emit(PersonalFileSaved());
        } else {
          emit(PersonalFileIdError());
        }
      }
    } catch (e) {
      emit(SavePersonalFileFailed());
    }
  }

  bool _validateNicknameAndId(List<Publisher> publisherList, Member member) {
    for (var publisher in publisherList) {
      if (_equalsIgnoreCase(publisher.title, member.nickname)) {
        return false;
      }
    }
    return true;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }
}
