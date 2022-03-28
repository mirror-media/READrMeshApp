import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/personalFileService.dart';

part 'followingList_state.dart';

class FollowingListCubit extends Cubit<FollowingListState> {
  FollowingListCubit() : super(FollowingListInitial());
  final PersonalFileService _personalFileService = PersonalFileService();

  fetchFollowingList({required Member viewMember}) async {
    try {
      var result = await _personalFileService.fetchFollowingList(viewMember);

      emit(FollowingListLoaded(
        followingMemberList: result['followingList'],
        followPublisherList: await _personalFileService.fetchFollowPublisher(
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
          await _personalFileService.fetchFollowingList(viewMember, skip: skip);
      emit(FollowingListLoadMoreSuccess(result['followingList']));
    } catch (e) {
      emit(FollowingListLoadMoreFailed(determineException(e)));
    }
  }
}
