import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/services/personalFileService.dart';

class InitialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PersonalFileCubit(personalFileRepos: PersonalFileService()),
        ),
      ],
      child: RootPage(),
    );
  }
}
