import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/personalFileWidget.dart';

class PersonalFilePage extends StatelessWidget {
  final Member viewMember;
  final Member currentMember;
  final bool isFromBottomTab;
  const PersonalFilePage({
    required this.viewMember,
    required this.currentMember,
    this.isFromBottomTab = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isVisitor = currentMember.memberId == '-1';
    bool isMine = viewMember.memberId == currentMember.memberId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (BuildContext context) => PersonalFileCubit(),
        child: PersonalFileWidget(
          viewMember: viewMember,
          isMine: isMine,
          isVisitor: isVisitor,
          currentMember: currentMember,
          isFromBottomTab: isFromBottomTab,
        ),
      ),
    );
  }
}
