import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/followingBlock.dart';
import 'package:readr/pages/home/latestComment/latestCommentsBlock.dart';
import 'package:readr/pages/home/latestNewsBlock.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowBlock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
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

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // print('User is currently signed out!');
      } else {
        // print('User is signed in!');
      }
      _fetchHomeScreen();
    });
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
      listener: (context, state) {
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
      },
      builder: (context, state) {
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
          print('HomeReloadFailed: ${error.message}');
          return _buildHomeContent();
        }

        if (state is HomeRefresh ||
            state is LoadingMoreNews ||
            state is LoadMoreNewsFailed ||
            state is HomeReloading ||
            state is HomeRefreshing) {
          return _buildHomeContent();
        }

        if (state is LoadingMoreFollowingPicked) {
          _isLoadingMoreFollowingPicked = true;
          return _buildHomeContent();
        }

        if (state is LoadMoreFollowingPickedFailed) {
          final error = state.error;
          print('LoadMoreFollowingPickedFailed: ${error.message()}');
          _isLoadingMoreFollowingPicked = false;
          return _buildHomeContent();
        }

        if (state is LoadMoreFollowingPickedSuccess) {
          _followingStories.addAll(state.newFollowingStories);
          _isLoadingMoreFollowingPicked = false;
          return _buildHomeContent();
        }

        if (state is LoadMoreNewsSuccess) {
          if (state.newLatestNews.length < 10) {
            _noMoreLatestNews = true;
          }
          _allLatestNews.addAll(state.newLatestNews);
          return _buildHomeContent();
        }

        if (state is HomeLoaded) {
          _followingStories = state.followingStories;
          _allLatestNews = state.allLatestNews;
          _latestComments = state.latestComments;
          _recommendedMembers = state.recommendedMembers;
          _recommendedPublishers = state.recommendedPublishers;
          return _buildHomeContent();
        }

        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => _reloadHomeScreen(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FollowingBlock(
              _followingStories,
              _isLoadingMoreFollowingPicked,
              _recommendedMembers,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 8.5,
              color: homeScreenBackgroundColor,
            ),
          ),
          SliverToBoxAdapter(
            child: RecommendFollowBlock(_recommendedMembers),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 8.5,
              color: homeScreenBackgroundColor,
            ),
          ),
          SliverToBoxAdapter(
            child: LatestCommentsBlock(_latestComments),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 8.5,
              color: homeScreenBackgroundColor,
            ),
          ),
          _latestNewsBar(),
          SliverToBoxAdapter(
            child: LatestNewsBlock(
              allLatestNews: _allLatestNews,
              recommendedPublishers: _recommendedPublishers,
              showFullScreenAd: _showFullScreenAd,
              showPaywall: _showPaywall,
              noMore: _noMoreLatestNews,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      title: const Text(
        'Logo',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
          ),
        )
      ],
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
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.expand_more_outlined,
              color: Colors.black38,
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
                        color: Colors.black26,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '自訂您想看到的新聞',
                      style: TextStyle(
                        color: Colors.black54,
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
                    activeColor: Colors.black87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: const Text(
                      '付費文章',
                      style: TextStyle(
                        color: Colors.black87,
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
                    activeColor: Colors.black87,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: const Text(
                      '蓋板廣告',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Divider(
                    color: Colors.black12,
                    height: 0.5,
                    thickness: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        _showPaywall = showPaywall;
                        _showFullScreenAd = showFullScreenAd;
                        await prefs.setBool('showPaywall', _showPaywall);
                        await prefs.setBool(
                            'showFullScreenAd', _showFullScreenAd);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '篩選',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black87,
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
