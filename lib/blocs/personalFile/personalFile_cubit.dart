import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:readr/services/visitorService.dart';

part 'personalFile_state.dart';

class PersonalFileCubit extends Cubit<PersonalFileState> {
  PersonalFileCubit() : super(PersonalFileInitial());

  final PersonalFileService _personalFileService = PersonalFileService();
  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  fetchMemberData(
    Member viewMember,
    Member currentMember, {
    bool isReload = false,
  }) async {
    if (isReload) {
      emit(PersonalFileReloading());
    } else {
      emit(PersonalFileLoading());
    }

    late Member viewMemberData;
    late Member currentMemberData;
    Future fetchCurrentMember;
    if (currentMember.memberId != '-1') {
      fetchCurrentMember = _memberService
          .fetchMemberData()
          .then((value) => currentMemberData = value);
    } else {
      fetchCurrentMember = _visitorService
          .fetchMemberData()
          .then((value) => currentMemberData = value);
    }
    await Future.wait([
      _personalFileService
          .fetchMemberData(viewMember)
          .then((value) => viewMemberData = value),
      fetchCurrentMember,
    ]);

    emit(PersonalFileLoaded(viewMemberData, currentMemberData));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (error is SocketException) {
      emit(PersonalFileError(
        error: NoInternetException('No Internet'),
      ));
    } else if (error is HttpException) {
      emit(PersonalFileError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } else if (error is FormatException) {
      emit(PersonalFileError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } else if (error is FetchDataException) {
      emit(PersonalFileError(
        error: NoInternetException('Error During Communication'),
      ));
    } else if (error is BadRequestException ||
        error is UnauthorisedException ||
        error is InvalidInputException) {
      emit(PersonalFileError(
        error: Error400Exception('Unauthorised'),
      ));
    } else if (error is InternalServerErrorException) {
      emit(PersonalFileError(
        error: Error500Exception('Internal Server Error'),
      ));
    } else {
      emit(PersonalFileError(
        error: UnknownException(error.toString()),
      ));
    }
    super.onError(error, stackTrace);
  }
}
