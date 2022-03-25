import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/readrListItem.dart';
import 'package:readr/services/tabStoryListService.dart';

part 'tabStoryList_event.dart';
part 'tabStoryList_state.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvent, TabStoryListState> {
  final TabStoryListServices _tabStoryListServices = TabStoryListServices();
  int _storySkip = 0;
  int _projectSkip = 0;
  bool _noMore = false;

  TabStoryListBloc() : super(TabStoryListInitial()) {
    on<TabStoryListEvent>((event, emit) async {
      try {
        Map<String, List<NewsListItem>> result = {
          'story': [],
          'project': [],
        };
        bool loadMore = false;
        if (event is FetchStoryList) {
          emit(TabStoryListLoading());
          result = await _tabStoryListServices.fetchStoryList();
        } else if (event is FetchStoryListByCategorySlug) {
          emit(TabStoryListLoading());
          result = await _tabStoryListServices
              .fetchStoryListByCategorySlug(event.slug);
        } else if (event is FetchNextPage) {
          emit(TabStoryListLoadingMore());
          loadMore = true;
          result = await _tabStoryListServices.fetchStoryList(
            storySkip: _storySkip,
            projectSkip: _projectSkip,
            storyFirst: 12,
          );
        } else if (event is FetchNextPageByCategorySlug) {
          emit(TabStoryListLoadingMore());
          loadMore = true;
          result = await _tabStoryListServices.fetchStoryListByCategorySlug(
            event.slug,
            storySkip: _storySkip,
            projectSkip: _projectSkip,
            storyFirst: 12,
          );
        }
        if (result['story']!.length < 12 && loadMore) {
          _noMore = true;
        }

        _storySkip = _storySkip + result['story']!.length;
        _projectSkip = _projectSkip + result['project']!.length;

        emit(TabStoryListLoaded(
            _mixTwoList(
              storyList: result['story']!,
              projectList: result['project']!,
              loadMore: loadMore,
            ),
            _noMore));
      } catch (e) {
        if (event is FetchStoryList || event is FetchStoryListByCategorySlug) {
          emit(TabStoryListError(determineException(e)));
        } else {
          emit(TabStoryListLoadingMoreFailed(determineException(e)));
        }
      }
    });
  }

  List<ReadrListItem> _mixTwoList({
    required List<NewsListItem> storyList,
    required List<NewsListItem> projectList,
    bool loadMore = false,
  }) {
    List<ReadrListItem> tempList = [];
    for (var item in storyList) {
      tempList.add(ReadrListItem(item, false));
    }
    if (tempList.isEmpty) {
      for (var item in projectList) {
        tempList.add(ReadrListItem(item, true));
      }
    } else {
      int pointer = loadMore ? 0 : 6;
      for (int i = 0; i < projectList.length; i++) {
        if (pointer < tempList.length) {
          tempList.insert(pointer, ReadrListItem(projectList[i], true));
          pointer = pointer + 7;
        } else {
          tempList.add(ReadrListItem(projectList[i], true));
        }
      }
    }
    return tempList;
  }
}
