import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/chooseFollow/chooseFollow_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/choosePublisher/choosePublisherWidget.dart';
import 'package:readr/services/recommendService.dart';

class ChoosePublisherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          '歡迎使用',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) =>
              ChooseFollowCubit(recommendRepos: RecommendService()),
          child: const ChoosePublisherWidget(),
        ),
      ),
    );
  }
}
