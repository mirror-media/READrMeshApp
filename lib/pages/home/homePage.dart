import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/pages/home/homeWidget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HomeWidget(),
      ),
      backgroundColor: Colors.white,
    );
  }
}
