import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/pages/home/homeWidget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: HomeWidget(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      title: const Text(
        'NewSelect',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
    );
  }
}
