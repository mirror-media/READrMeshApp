import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/personalFileService.dart';

part 'followingList_state.dart';

class FollowingListCubit extends Cubit<FollowingListState> {
  final PersonalFileRepos personalFileRepos;
  FollowingListCubit({required this.personalFileRepos})
      : super(FollowingListInitial());

  fetchFollowingList({required Member viewMember}) async {
    try {
      var result = await personalFileRepos.fetchFollowingList(viewMember);

      emit(FollowingListLoaded(
        followingMemberList: result['followingList'],
        followPublisherList: await personalFileRepos.fetchFollowPublisher(
          viewMember,
        ),
        followingMemberCount: result['followingMemberCount'],
      ));
    } catch (e) {
      emit(FollowingListError(determineException(e)));
    }
  }

  loadMore({
    required Member viewMember,
    required int skip,
  }) async {
    try {
      var result =
          await personalFileRepos.fetchFollowingList(viewMember, skip: skip);
      emit(FollowingListLoadMoreSuccess(result['followingList']));
    } catch (e) {
      emit(FollowingListLoadMoreFailed(determineException(e)));
    }
  }
}
