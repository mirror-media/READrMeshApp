import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/recommendService.dart';

part 'chooseFollow_state.dart';

class ChooseFollowCubit extends Cubit<ChooseFollowState> {
  ChooseFollowCubit() : super(ChooseFollowInitial());
  final RecommendService _recommendService = RecommendService();

  fetchAllPublishers() async {
    emit(ChooseFollowLoading());
    try {
      List<Publisher> publishers = await _recommendService.fetchAllPublishers();
      await UserHelper.instance.fetchUserData();
      emit(PublisherListLoaded(publishers));
    } catch (e) {
      emit(ChooseFollowError(determineException(e)));
    }
  }

  fetchRecommendMember() async {
    emit(ChooseFollowLoading());
    try {
      List<Member> members = await _recommendService.fetchRecommendedMembers();
      emit(MemberListLoaded(members));
    } catch (e) {
      emit(ChooseFollowError(determineException(e)));
    }
  }
}
