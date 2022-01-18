import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/memberService.dart';

part 'state.dart';

class MemberCenterCubit extends Cubit<MemberCenterState> {
  MemberCenterCubit() : super(MemberCenterInitial());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MemberService _memberService = MemberService();
  bool _alreadyGetInfo = false;
  late final String _version;
  late final String _buildNumber;

  fetchPackageInfo() async {
    print('Fetch info');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    _alreadyGetInfo = true;
  }

  fetchMember() async {
    emit(MemberCenterLoading());
    if (!_alreadyGetInfo) await fetchPackageInfo();
    if (_auth.currentUser != null) {
      await fetchMemberData();
    } else {
      emit(MemberCenterLoaded(
        buildNumber: _buildNumber,
        version: _version,
        member: null,
      ));
    }
  }

  fetchMemberData() async {
    try {
      print('Fetch member data');
      Member? memberData = await _memberService.fetchMemberData();
      emit(MemberCenterLoaded(
        buildNumber: _buildNumber,
        version: _version,
        member: memberData,
      ));
    } catch (exception) {
      print('Fetch member failed, logout firebase');
      print('exception:  $exception');
      await _auth.signOut();
      emit(MemberLoadFailed(
        buildNumber: _buildNumber,
        version: _version,
      ));
    }
  }

  logout() async {
    await _auth.signOut();
    await fetchMember();
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
