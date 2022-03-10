import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/tabStoryList/tabStoryList_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/models/readrListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/readrProjectItem.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/pages/shared/latestNewsItem.dart';
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
  bool _isLoading = false;
  bool _noMore = false;
  final List<ReadrListItem> _mixedList = [];

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
        if (state is TabStoryListError) {
          final error = state.error;
          print('TabStoryListError: ${error.message}');

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

        if (state is TabStoryListLoaded) {
          _mixedList.addAll(state.mixedList);
          _isLoading = false;
          _noMore = state.noMore;

          if (_mixedList.isEmpty) {
            return TabContentNoResultWidget();
          }

          return _tabStoryList(context);
        }

        if (state is TabStoryListLoadingMore) {
          return _tabStoryList(context);
        }

        if (state is TabStoryListLoadingMoreFailed) {
          if (widget.categorySlug == 'latest') {
            _fetchNextPage();
          } else {
            _fetchNextPageByCategorySlug();
          }
          _isLoading = false;
          return _tabStoryList(context);
        }

        // state is Init, loading, or other
        return HomeSkeletonScreen();
      },
    );
  }

  Widget _tabStoryList(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20),
        separatorBuilder: (context, index) {
          if (_mixedList[index].isProject) {
            return const SizedBox(
              height: 36,
            );
          }

          if (index + 1 < _mixedList.length) {
            if (_mixedList[index + 1].isProject) {
              return const SizedBox(
                height: 36,
              );
            }
          }

          if (index == _mixedList.length - 1) {
            return Container();
          }

          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              color: Colors.black12,
              thickness: 0.5,
              height: 0.5,
              indent: 20,
              endIndent: 20,
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (index == _mixedList.length) {
            return _loadMoreWidget();
          }

          if (_mixedList[index].isProject) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ReadrProjectItem(
                _mixedList[index].newsListItem,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LatestNewsItem(
              _mixedList[index].newsListItem,
              hidePublisher: true,
            ),
          );
        },
        itemCount: _mixedList.length + 1,
      ),
    );
  }

  Widget _loadMoreWidget() {
    if (_noMore) {
      return Column(
        children: [
          Container(
            height: 16,
            color: Colors.white,
          ),
          Container(
            color: homeScreenBackgroundColor,
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            color: homeScreenBackgroundColor,
            child: RichText(
              text: const TextSpan(
                text: '🎉 ',
                style: TextStyle(
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '你已看完所有新聞囉',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: homeScreenBackgroundColor,
            height: 145,
          ),
        ],
      );
    }

    if (!_isLoading) {
      if (widget.categorySlug == 'latest') {
        _fetchNextPage();
      } else {
        _fetchNextPageByCategorySlug();
      }
      _isLoading = true;
    }

    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
