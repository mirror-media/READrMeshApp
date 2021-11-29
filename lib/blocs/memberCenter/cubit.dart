import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';

part 'state.dart';

class MemberCenterCubit extends Cubit<MemberCenterState> {
  MemberCenterCubit() : super(MemberCenterInitial());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  fetchMemberAndInfo() async {
    print('FetchMemberAndInfo');
    emit(MemberCenterLoading());
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    Member? member;
    if (_auth.currentUser != null) {
      member = Member(
        email: _auth.currentUser!.email!,
        firebaseId: _auth.currentUser!.uid,
      );
    }
    emit(MemberCenterLoaded(
      buildNumber: buildNumber,
      version: version,
      member: member,
    ));
  }

  logout() async {
    await _auth.signOut();
    await fetchMemberAndInfo();
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (error is SocketException) {
      emit(MemberCenterError(
        error: NoInternetException('No Internet'),
      ));
    } else if (error is HttpException) {
      emit(MemberCenterError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } else if (error is FormatException) {
      emit(MemberCenterError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } else if (error is FetchDataException) {
      emit(MemberCenterError(
        error: NoInternetException('Error During Communication'),
      ));
    } else if (error is BadRequestException ||
        error is UnauthorisedException ||
        error is InvalidInputException) {
      emit(MemberCenterError(
        error: Error400Exception('Unauthorised'),
      ));
    } else if (error is InternalServerErrorException) {
      emit(MemberCenterError(
        error: Error500Exception('Internal Server Error'),
      ));
    } else {
      emit(MemberCenterError(
        error: UnknownException(error.toString()),
      ));
    }
    super.onError(error, stackTrace);
  }
}
