import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/followingBlock.dart';
import 'package:readr/pages/home/latestComment/latestCommentsBlock.dart';
import 'package:readr/pages/home/latestNewsBlock.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowBlock.dart';
import 'package:readr/pages/shared/homeAppBar.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<NewsListItem> _followingStories = [];
  bool _isLoadingMoreFollowingPicked = false;
  bool _showPaywall = true;
  bool _showFullScreenAd = true;
  List<NewsListItem> _allLatestNews = [];
  bool _noMoreLatestNews = false;
  List<NewsListItem> _latestComments = [];
  List<MemberFollowableItem> _recommendedMembers = [];
  List<PublisherFollowableItem> _recommendedPublishers = [];
  bool _moreFollowingPickedLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeScreen();
  }

  _fetchHomeScreen() async {
    context.read<HomeBloc>().add(InitialHomeScreen());
  }

  _reloadHomeScreen() async {
    context.read<HomeBloc>().add(ReloadHomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is HomeReloadFailed ||
            state is LoadMoreFollowingPickedFailed ||
            state is LoadMoreNewsFailed) {
          Fluttertoast.showToast(
            msg: "載入失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        if (state is HomeLoaded) {
          if (state.showSyncToast) {
            Widget toast = Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: const Color.fromRGBO(0, 9, 40, 0.66),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 6.0,
                  ),
                  Text(
                    '已同步追蹤名單',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
            showToastWidget(
              toast,
              context: context,
              animation: StyledToastAnimation.slideFromTop,
              reverseAnimation: StyledToastAnimation.slideToTop,
              position: StyledToastPosition.top,
              startOffset: const Offset(0.0, -3.0),
              reverseEndOffset: const Offset(0.0, -3.0),
              duration: const Duration(seconds: 3),
              //Animation duration   animDuration * 2 <= duration
              animDuration: const Duration(milliseconds: 250),
              curve: Curves.linear,
              reverseCurve: Curves.linear,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              const HomeAppBar(),
              SliverFillRemaining(
                child: HomeSkeletonScreen(),
              ),
            ],
          );
        }
        if (state is HomeError) {
          final error = state.error;
          print('HomePageError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchHomeScreen(),
            hideAppbar: true,
          );
        }

        if (state is HomeReloadFailed) {
          final error = state.error;
          print('HomeReloadFailed: ${error.toString()}');
        }

        return _buildHomeContent();
      },
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => _reloadHomeScreen(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const HomeAppBar(),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  _followingStories = state.followingStories;
                  _recommendedMembers = state.recommendedMembers;
                  _moreFollowingPickedLoaded = false;
                }

                if (state is LoadingMoreFollowingPicked) {
                  _isLoadingMoreFollowingPicked = true;
                }

                if (state is LoadMoreFollowingPickedFailed) {
                  final error = state.error;
                  print('LoadMoreFollowingPickedFailed: ${error.message()}');
                  _isLoadingMoreFollowingPicked = false;
                }

                if (state is LoadMoreFollowingPickedSuccess) {
                  _followingStories.addAll(state.newFollowingStories);
                  _isLoadingMoreFollowingPicked = false;
                  _moreFollowingPickedLoaded = true;
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FollowingBlock(
                        _followingStories,
                        _isLoadingMoreFollowingPicked,
                        _recommendedMembers,
                        _moreFollowingPickedLoaded,
                      ),
                    ),
                    if (_followingStories.isNotEmpty ||
                        Get.find<UserService>().currentUser.following.isEmpty)
                      Container(
                        height: 8.5,
                        color: homeScreenBackgroundColor,
                      ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  _recommendedMembers = state.recommendedMembers;
                }

                if (_recommendedMembers.isEmpty) {
                  return Container();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: RecommendFollowBlock(_recommendedMembers),
                    ),
                    Container(
                      height: 8.5,
                      color: homeScreenBackgroundColor,
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  _latestComments = state.latestComments;
                }

                if (_latestComments.isEmpty) {
                  return Container();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: LatestCommentsBlock(_latestComments),
                    ),
                    Container(
                      height: 8.5,
                      color: homeScreenBackgroundColor,
                    ),
                  ],
                );
              },
            ),
          ),
          _latestNewsBar(),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  _noMoreLatestNews = false;
                  _allLatestNews = state.allLatestNews;
                  _recommendedPublishers = state.recommendedPublishers;
                  if (_allLatestNews.length < 10) {
                    _noMoreLatestNews = true;
                  }
                }

                if (state is LoadMoreNewsSuccess) {
                  if (state.newLatestNews.length < 10) {
                    _noMoreLatestNews = true;
                  }
                  _allLatestNews.addAll(state.newLatestNews);
                }

                return LatestNewsBlock(
                  allLatestNews: _allLatestNews,
                  recommendedPublishers: _recommendedPublishers,
                  showFullScreenAd: _showFullScreenAd,
                  showPaywall: _showPaywall,
                  noMore: _noMoreLatestNews,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestNewsBar() {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 1,
      pinned: true,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: () async {
          await _showFilterBottomSheet(context);
        },
        child: Row(
          children: const [
            Text(
              '所有最新文章',
              style: TextStyle(
                  color: readrBlack87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.expand_more_outlined,
              color: readrBlack30,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    bool showPaywall = _showPaywall;
    bool showFullScreenAd = _showFullScreenAd;
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(20),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Material(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.only(top: 16),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: readrBlack20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '自訂您想看到的新聞',
                      style: TextStyle(
                        color: readrBlack50,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: showPaywall,
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        showPaywall = value!;
                      });
                    },
                    activeColor: readrBlack87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: const Text(
                      '付費文章',
                      style: TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: showFullScreenAd,
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        showFullScreenAd = value!;
                      });
                    },
                    activeColor: readrBlack87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: const Text(
                      '蓋板廣告',
                      style: TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Divider(
                    color: readrBlack10,
                    height: 0.5,
                    thickness: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 17),
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        _showPaywall = showPaywall;
                        _showFullScreenAd = showFullScreenAd;
                        await prefs.setBool('showPaywall', _showPaywall);
                        await prefs.setBool(
                            'showFullScreenAd', _showFullScreenAd);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: readrBlack87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        '篩選',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      setState(() {});
    });
  }
}
