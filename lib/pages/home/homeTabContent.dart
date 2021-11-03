import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/tabStoryList/bloc.dart';
import 'package:readr/blocs/tabStoryList/events.dart';
import 'package:readr/blocs/tabStoryList/states.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/pages/home/homeStoryListItem.dart';
import 'package:readr/pages/home/homeStoryProjectItem.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';
import 'package:shimmer/shimmer.dart';

class HomeTabContent extends StatefulWidget {
  final String categorySlug;
  const HomeTabContent({
    required this.categorySlug,
  });

  @override
  _HomeTabContentState createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  bool loadMoreFailed = false;
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

  _fetchStoryList() async {
    context.read<TabStoryListBloc>().add(FetchStoryList());
  }

  _fetchNextPage() async {
    context.read<TabStoryListBloc>().add(FetchNextPage());
  }

  _fetchStoryListByCategorySlug() async {
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
    return BlocConsumer<TabStoryListBloc, TabStoryListState>(
      listener: (BuildContext context, TabStoryListState state) async {
        if (state.status == TabStoryListStatus.error) {
          await context.pushRoute(ErrorRoute(
              error: state.error, needPop: true, onPressed: () => true));

          if (widget.categorySlug == 'latest') {
            _fetchStoryList();
          } else {
            _fetchStoryListByCategorySlug();
          }
        }
      },
      listenWhen: (previous, current) {
        if (previous.status == TabStoryListStatus.loadingMore) {
          if (current.status == TabStoryListStatus.error) {
            if (!loadMoreFailed) {
              Fluttertoast.showToast(
                msg: "加載失敗",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
            loadMoreFailed = true;
          }
          return false;
        }
        return true;
      },
      builder: (BuildContext context, TabStoryListState state) {
        if (state.status == TabStoryListStatus.error) {
          final error = state.error;
          print('TabStoryListError: ${error.message}');
          if (loadMoreFailed) {
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

          return Container();
        }
        if (state.status == TabStoryListStatus.loaded) {
          StoryListItemList mixedStoryList = state.mixedStoryList!;
          loadMoreFailed = false;
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
          loadMoreFailed = false;
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
        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 0),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          height: 90,
                          width: 90,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.white,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              width: double.infinity,
                            ),
                            Container(
                              height: 20,
                              color: Colors.white,
                              width: (MediaQuery.of(context).size.width - 40) *
                                  0.52,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
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
            listItem = HomeStoryPjojectItem(
              projectListItem: mixedStoryList[index],
            );
          } else {
            listItem = HomeStoryListItem(
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
