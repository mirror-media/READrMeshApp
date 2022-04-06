import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/followerList/followerList_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/followerList/followerListWidget.dart';
import 'package:readr/services/personalFileService.dart';

class FollowerListPage extends StatelessWidget {
  final Member viewMember;
  const FollowerListPage({required this.viewMember});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FollowerListCubit(personalFileRepos: PersonalFileService()),
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
              color: readrBlack,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: readrBlack87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FollowerListWidget(
          viewMember: viewMember,
        ),
      ),
    );
  }
}
