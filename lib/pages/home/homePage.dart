import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
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
      backgroundColor: homeScreenBackgroundColor,
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      leading: const Text(
        'Logo',
        style: TextStyle(
          color: Colors.black,
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
}
