import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/followerList/followerList_cubit.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/followerList/followerListWidget.dart';

class FollowerListPage extends StatelessWidget {
  final Member viewMember;
  final Member currentMember;
  const FollowerListPage(
      {required this.viewMember, required this.currentMember});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FollowerListCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: Platform.isIOS,
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            viewMember.customId,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FollowerListWidget(
          viewMember: viewMember,
          currentMember: currentMember,
        ),
      ),
    );
  }
}
