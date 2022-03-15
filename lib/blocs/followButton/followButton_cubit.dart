import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/models/followableItem.dart';

part 'followButton_state.dart';

class FollowButtonCubit extends Cubit<FollowButtonState> {
  FollowButtonCubit() : super(FollowButtonInitial());

  updateLocalFollowing(FollowableItem item) {
    emit(FollowButtonTap());
    item.updateLocalList();
    emit(FollowButtonUpdating());
  }

  updateFollowing(FollowableItem item) async {
    item.isFollowed ? await item.addFollow() : await item.removeFollow();
    emit(FollowButtonUpdated());
  }
}
