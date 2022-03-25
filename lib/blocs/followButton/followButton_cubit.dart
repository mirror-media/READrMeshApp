import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/models/followableItem.dart';

part 'followButton_state.dart';

class FollowButtonCubit extends Cubit<FollowButtonState> {
  FollowButtonCubit() : super(FollowButtonInitial());

  updateLocalFollowing(FollowableItem item) {
    emit(FollowButtonTap());
    item.updateLocalList();
    EasyDebounce.debounce(item.id, const Duration(seconds: 1),
        () async => await updateFollowing(item));
    emit(FollowButtonUpdating());
  }

  updateFollowing(FollowableItem item) async {
    item.isFollowed ? await item.addFollow() : await item.removeFollow();
    emit(FollowButtonUpdated());
  }
}
