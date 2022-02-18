import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/exceptions.dart';
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
  final PersonalFileService _personalFileService = PersonalFileService();
  late final Member _viewMember;
  late final Member _currentMember;
  late final TabContentType _tabContentType;
  PersonalFileTabBloc() : super(PersonalFileTabInitial()) {
    on<PersonalFileTabEvent>((event, emit) async {
      try {
        if (event is FetchTabContent) {
          emit(PersonalFileTabLoading());
          _viewMember = event.viewMember;
          _currentMember = event.currentMember;
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
      return await _personalFileService.fetchPickData(
          _viewMember, _currentMember);
    } else if (_tabContentType == TabContentType.bookmark) {
      return await _personalFileService.fetchBookmark(_currentMember);
    }
  }

  dynamic _fetchMoreTabContent(DateTime lastItemPublishTime) async {
    if (_tabContentType == TabContentType.pick) {
      return await _personalFileService.fetchPickData(
          _viewMember, _currentMember,
          pickFilterTime: lastItemPublishTime);
    } else if (_tabContentType == TabContentType.bookmark) {
      return await _personalFileService.fetchBookmark(
        _currentMember,
        pickFilterTime: lastItemPublishTime,
      );
    }
  }
}
