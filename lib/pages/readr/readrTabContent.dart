import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/tabStoryList/bloc.dart';
import 'package:readr/blocs/readr/tabStoryList/events.dart';
import 'package:readr/blocs/readr/tabStoryList/states.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/readrStoryListItem.dart';
import 'package:readr/pages/readr/readrStoryProjectItem.dart';
import 'package:readr/pages/shared/storyListSkeletonScreen.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';

class ReadrTabContent extends StatefulWidget {
  final String categorySlug;
  const ReadrTabContent({
    required this.categorySlug,
  });

  @override
  _ReadrTabContentState createState() => _ReadrTabContentState();
}

class _ReadrTabContentState extends State<ReadrTabContent> {
  bool loadingMore = false;
  late StoryListItemList mixedStoryListTemp;
  @override
  void initState() {
    if (widget.categorySlug == 'latest') {
      _fetchStoryList();
    } else {
      _fetchStoryListByCategorySlug();
    }
    super.initState();
  }

  _fetchStoryList() {
    context.read<TabStoryListBloc>().add(FetchStoryList());
  }

  _fetchNextPage() async {
    context.read<TabStoryListBloc>().add(FetchNextPage());
  }

  _fetchStoryListByCategorySlug() {
    context
        .read<TabStoryListBloc>()
        .add(FetchStoryListByCategorySlug(widget.categorySlug));
  }

  _fetchNextPageByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchNextPageByCategorySlug(widget.categorySlug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
      builder: (BuildContext context, TabStoryListState state) {
        if (state.status == TabStoryListStatus.error) {
          final error = state.error;
          print('TabStoryListError: ${error.message}');
          if (loadingMore) {
            if (widget.categorySlug == 'latest') {
              _fetchNextPage();
            } else {
              _fetchNextPageByCategorySlug();
            }
            return _tabStoryList(
              mixedStoryList: mixedStoryListTemp,
              isLoading: true,
            );
          }

          if (widget.categorySlug == 'latest') {
            return ErrorPage(
              error: error,
              onPressed: () => _fetchNextPage(),
              hideAppbar: true,
            );
          } else {
            return ErrorPage(
              error: error,
              onPressed: () => _fetchNextPageByCategorySlug(),
              hideAppbar: true,
            );
          }
        }
        if (state.status == TabStoryListStatus.loaded) {
          StoryListItemList mixedStoryList = state.mixedStoryList!;
          loadingMore = false;
          mixedStoryListTemp = state.mixedStoryList!;
          if (mixedStoryList.isEmpty) {
            return TabContentNoResultWidget();
          }

          return _tabStoryList(
            mixedStoryList: mixedStoryList,
          );
        }

        if (state.status == TabStoryListStatus.loadingMore) {
          StoryListItemList mixedStoryList = state.mixedStoryList!;
          loadingMore = true;
          return _tabStoryList(
            mixedStoryList: mixedStoryList,
            isLoading: true,
          );
        }

        if (state.status == TabStoryListStatus.loadingMoreFail) {
          StoryListItemList mixedStoryList = state.mixedStoryList!;

          if (widget.categorySlug == 'latest') {
            _fetchNextPage();
          } else {
            _fetchNextPageByCategorySlug();
          }
          return _tabStoryList(
            mixedStoryList: mixedStoryList,
            isLoading: true,
          );
        }

        // state is Init, loading, or other
        return StoryListSkeletonScreen();
      },
    );
  }

  Widget _tabStoryList({
    required StoryListItemList mixedStoryList,
    bool isLoading = false,
  }) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 24.0),
        itemBuilder: (BuildContext context, int index) {
          if (!isLoading &&
              index == mixedStoryList.length - 5 &&
              mixedStoryList.length < mixedStoryList.allStoryCount) {
            if (widget.categorySlug == 'latest') {
              _fetchNextPage();
            } else {
              _fetchNextPageByCategorySlug();
            }
          }
          Widget listItem;
          if (mixedStoryList[index].isProject) {
            listItem = ReadrStoryPjojectItem(
              projectListItem: mixedStoryList[index],
            );
          } else {
            listItem = ReadrStoryListItem(
              storyListItem: mixedStoryList[index],
            );
          }

          return Column(
            children: [
              listItem,
              if (index == mixedStoryList.length - 1 && isLoading)
                _loadMoreWidget(),
            ],
          );
        },
        itemCount: mixedStoryList.length,
      ),
    );
  }

  Widget _loadMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}
