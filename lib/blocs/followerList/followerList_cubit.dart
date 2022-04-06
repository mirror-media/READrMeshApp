import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/personalFileService.dart';

part 'followerList_state.dart';

class FollowerListCubit extends Cubit<FollowerListState> {
  final PersonalFileRepos personalFileRepos;
  FollowerListCubit({required this.personalFileRepos})
      : super(FollowerListInitial());

  fetchFollowerList({required Member viewMember}) async {
    try {
      emit(FollowerListLoaded(
          await personalFileRepos.fetchFollowerList(viewMember)));
    } catch (e) {
      emit(FollowerListError(determineException(e)));
    }
  }

  loadMore({
    required Member viewMember,
    required int skip,
  }) async {
    try {
      emit(FollowerListLoadMoreSuccess(
          await personalFileRepos.fetchFollowerList(viewMember, skip: skip)));
    } catch (e) {
      emit(FollowerListLoadMoreFailed(determineException(e)));
    }
  }
}
