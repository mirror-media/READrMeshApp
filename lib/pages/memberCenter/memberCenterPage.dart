import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/memberCenter/cubit.dart';
import 'package:readr/pages/memberCenter/memberCenterWidget.dart';

class MemberCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MemberCenterCubit(),
      child: MemberCenterWidget(),
    );
  }
}
