import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/recommendService.dart';

part 'chooseFollow_state.dart';

class ChooseFollowCubit extends Cubit<ChooseFollowState> {
  final RecommendRepos recommendRepos;
  ChooseFollowCubit({required this.recommendRepos})
      : super(ChooseFollowInitial());

  fetchAllPublishers() async {
    emit(ChooseFollowLoading());
    try {
      List<Publisher> publishers = await recommendRepos.fetchAllPublishers();
      await Get.find<UserService>().fetchUserData();
      emit(PublisherListLoaded(publishers));
    } catch (e) {
      emit(ChooseFollowError(determineException(e)));
    }
  }

  fetchRecommendMember() async {
    emit(ChooseFollowLoading());
    try {
      List<Member> members = await recommendRepos.fetchRecommendedMembers();
      emit(MemberListLoaded(members));
    } catch (e) {
      emit(ChooseFollowError(determineException(e)));
    }
  }
}
