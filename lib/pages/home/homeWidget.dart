import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/followingBlock.dart';
import 'package:readr/pages/home/latestCommentsBlock.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Map<String, dynamic> _data = {};

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeReloadFailed) {
          Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
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

        if (state is HomeReloading) {
          return _buildHomeList();
        }

        if (state is HomeReloadFailed) {
          return _buildHomeList();
        }

        if (state is HomeLoaded) {
          _data = state.data;
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
      onRefresh: () => _fetchHomeScreen(),
      child: ListView(
        children: [
          FollowingBlock(_data['followingNewsList']),
          const SizedBox(height: 8.5),
          LatestCommentsBlock(_data['latestCommentsNewsList'], _data['myId']),
          const SizedBox(height: 8.5),
        ],
      ),
    );
  }
}
