import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/personalFileWidget.dart';
import 'package:readr/services/personalFileService.dart';

class PersonalFilePage extends StatelessWidget {
  final Member viewMember;
  final bool isFromBottomTab;
  const PersonalFilePage({
    required this.viewMember,
    this.isFromBottomTab = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isMine =
        viewMember.memberId == Get.find<UserService>().currentUser.memberId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (BuildContext context) =>
            PersonalFileCubit(personalFileRepos: PersonalFileService()),
        child: PersonalFileWidget(
          viewMember: viewMember,
          isMine: isMine,
          isVisitor: Get.find<UserService>().isVisitor,
          isFromBottomTab: isFromBottomTab,
        ),
      ),
    );
  }
}
