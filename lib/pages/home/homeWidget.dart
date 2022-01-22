import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/member.dart';
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
  bool _isUpdating = false;

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
          return _buildHomeList();
        }

        if (state is UpdatingFollowing) {
          _tempFollowingData = _currentMember.following;
          _currentMember.following = state.tempNewFollowingMembers;
          return _buildHomeList();
        }

        if (state is UpdateFollowingFailed) {
          final error = state.error;
          print('UpdateFollowingFailed: ${error.message}');
          _currentMember.following = _tempFollowingData;
          return _buildHomeList();
        }

        if (state is UpdateFollowingSuccess) {
          _currentMember.following = state.newFollowingMembers;
          return _buildHomeList();
        }

        if (state is HomeLoaded) {
          _data = state.data;
          _currentMember = _data['member'];
          return _buildHomeList();
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildHomeList() {
    return RefreshIndicator(
      onRefresh: () => _reloadHomeScreen(),
      child: ListView(
        children: [
          FollowingBlock(_data['followingStories'], _currentMember),
          const SizedBox(height: 8.5),
          LatestCommentsBlock(_data['latestComments'], _currentMember),
          const SizedBox(height: 8.5),
          LatestNewsBlock(
            _data['allLatestNews'],
            _data['recommendedMembers'],
            _currentMember,
          ),
          Container(
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Center(
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
          )),
          const SizedBox(height: 145),
        ],
      ),
    );
  }
}
