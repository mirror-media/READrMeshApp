import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/home/homeWidget.dart';

class HomePage extends StatelessWidget {
  final Member currentMember;
  const HomePage(this.currentMember);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: HomeWidget(currentMember),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
