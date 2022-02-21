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
      int checkResult = _validateNicknameAndId(_publisherList, member);
      if (checkResult == 1) {
        emit(PersonalFileNicknameError());
      } else if (checkResult == 2) {
        emit(PersonalFileIdError());
      } else {
        bool result = await _memberService.updateMember(member);
        if (result) {
          emit(PersonalFileSaved());
        } else {
          emit(SavePersonalFileFailed());
        }
      }
    } catch (e) {
      emit(SavePersonalFileFailed());
    }
  }

  //return 0 mean pass, 1 mean nickname failed, 2 mean customId failed
  int _validateNicknameAndId(List<Publisher> publisherList, Member member) {
    for (var publisher in publisherList) {
      if (_equalsIgnoreCase(publisher.title, member.nickname)) {
        return 1;
      } else if (_equalsIgnoreCase(publisher.customId!, member.customId)) {
        return 2;
      }
    }
    return 0;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }
}
