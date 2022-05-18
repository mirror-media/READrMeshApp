import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/personalFileService.dart';

part 'personalFileTab_event.dart';
part 'personalFileTab_state.dart';

enum TabContentType {
  pick,
  collection,
  bookmark,
}

class PersonalFileTabBloc
    extends Bloc<PersonalFileTabEvent, PersonalFileTabState> {
  final PersonalFileRepos personalFileRepos;
  late final Member _viewMember;
  late final TabContentType _tabContentType;
  PersonalFileTabBloc({required this.personalFileRepos})
      : super(PersonalFileTabInitial()) {
    on<PersonalFileTabEvent>((event, emit) async {
      try {
        if (event is FetchTabContent) {
          emit(PersonalFileTabLoading());
          _viewMember = event.viewMember!;
          _tabContentType = event.tabContentType;
          emit(PersonalFileTabLoaded(await _fetchTabContent()));
        } else if (event is ReloadTab) {
          emit(PersonalFileTabReloading());
          emit(PersonalFileTabLoaded(await _fetchTabContent()));
        } else if (event is LoadMore) {
          emit(PersonalFileTabLoadingMore());
          emit(PersonalFileTabLoadMoreSuccess(
              await _fetchMoreTabContent(event.lastPickTime)));
        }
      } catch (e) {
        if (event is LoadMore) {
          emit(PersonalFileTabLoadMoreFailed(e));
        } else if (event is ReloadTab) {
          emit(PersonalFileTabReloadFailed(e));
        } else {
          emit(PersonalFileTabError(determineException(e)));
        }
      }
    });
  }

  dynamic _fetchTabContent() async {
    if (_tabContentType == TabContentType.pick) {
      return await personalFileRepos.fetchPickData(_viewMember);
    } else if (_tabContentType == TabContentType.bookmark) {
      return await personalFileRepos.fetchBookmark();
    }
  }

  dynamic _fetchMoreTabContent(DateTime lastItemPublishTime) async {
    if (_tabContentType == TabContentType.pick) {
      return await personalFileRepos.fetchPickData(_viewMember,
          pickFilterTime: lastItemPublishTime);
    } else if (_tabContentType == TabContentType.bookmark) {
      return await personalFileRepos.fetchBookmark(
        pickFilterTime: lastItemPublishTime,
      );
    }
  }
}
