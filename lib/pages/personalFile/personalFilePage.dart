import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/personalFileWidget.dart';

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
        viewMember.memberId == UserHelper.instance.currentUser.memberId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (BuildContext context) => PersonalFileCubit(),
        child: PersonalFileWidget(
          viewMember: viewMember,
          isMine: isMine,
          isVisitor: UserHelper.instance.isVisitor,
          isFromBottomTab: isFromBottomTab,
        ),
      ),
    );
  }
}
