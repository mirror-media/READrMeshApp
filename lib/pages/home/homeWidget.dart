import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/followingBlock.dart';
import 'package:readr/pages/home/latestCommentsBlock.dart';
import 'package:readr/pages/home/latestNewsBlock.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Map<String, dynamic> _data = {};
  late Member _currentMember;
  List<Member>? _tempFollowingData;
  List<NewsListItem> _followingStories = [];
  bool _isLoadingMoreFollowingPicked = false;

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
        if (state is HomeReloadFailed) {
          Fluttertoast.showToast(
            msg: "載入失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (state is UpdateFollowingFailed) {
          String text = '';
          if (state.isFollowed) {
            text = "取消追蹤失敗，請稍後再試一次";
          } else {
            text = "新增追蹤失敗，請稍後再試一次";
          }
          Fluttertoast.showToast(
            msg: text,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (state is LoadMoreFollowingPickedFailed) {
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

        if (state is UpdatingFollowing) {
          _tempFollowingData = _currentMember.following;
          _currentMember.following = state.newFollowingMembers;
          return _buildHomeContent();
        }

        if (state is UpdateFollowingSuccess) {
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

        if (state is UpdateFollowingFailed) {
          final error = state.error;
          print('UpdateFollowingFailed: ${error.message}');
          _currentMember.following = _tempFollowingData;
          return _buildHomeContent();
        }

        if (state is HomeLoaded) {
          _data = state.data;
          _currentMember = _data['member'];
          _followingStories = _data['followingStories'];
          return _buildHomeContent();
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => _reloadHomeScreen(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FollowingBlock(
              _followingStories,
              _currentMember,
              _isLoadingMoreFollowingPicked,
              _data['recommendedMembers'],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 8.5,
              color: homeScreenBackgroundColor,
            ),
          ),
          SliverToBoxAdapter(
            child: LatestCommentsBlock(_data['latestComments'], _currentMember),
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
              _data['allLatestNews'],
              _data['recommendedMembers'],
              _currentMember,
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
    String barText = '所有最新文章';
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 1,
      pinned: true,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Text(
              barText,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more_outlined,
              color: Colors.black38,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
