import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/editPersonalFile/editPersonalFile_cubit.dart';
import 'package:readr/pages/personalFile/editPersonalFile/editPersonalFileWidget.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class EditPersonalFilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (BuildContext context) => EditPersonalFileCubit(
            memberRepos: MemberService(),
            personalFileRepos: PersonalFileService()),
        child: EditPersonalFileWidget(),
      ),
    );
  }
}
