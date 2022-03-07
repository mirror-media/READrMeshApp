import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/chooseFollow/chooseFollow_cubit.dart';
import 'package:readr/pages/loginMember/chooseMember/chooseMemberWidget.dart';

class ChooseMemberPage extends StatelessWidget {
  final bool isFromPublisher;
  const ChooseMemberPage(this.isFromPublisher);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS,
        elevation: 0,
        title: const Text(
          '推薦追蹤',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        leading: isFromPublisher
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => ChooseFollowCubit(),
          child: const ChooseMemberWidget(),
        ),
      ),
    );
  }
}
