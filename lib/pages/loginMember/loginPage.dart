import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/login/login_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginWidget.dart';

class LoginPage extends StatelessWidget {
  final bool fromComment;
  final bool fromOnboard;
  const LoginPage({this.fromComment = false, this.fromOnboard = false});

  @override
  Widget build(BuildContext context) {
    late final String appBarTitle;
    if (fromOnboard) {
      appBarTitle = '開始使用';
    } else if (fromComment) {
      appBarTitle = '加入討論';
    } else {
      appBarTitle = '繼續使用';
    }
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            appBarTitle,
            style: const TextStyle(
              color: readrBlack,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            if (!fromOnboard)
              IconButton(
                icon: const Icon(
                  Icons.close_outlined,
                  color: readrBlack87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            // if (fromOnboard)
            //   TextButton(
            //     onPressed: () {
            //       AutoRouter.of(context).replace(const ChoosePublisherRoute());
            //     },
            //     child: const Text(
            //       '略過',
            //       style: TextStyle(
            //         color: Colors.blue,
            //         fontSize: 18,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //   ),
          ],
        ),
        body: SafeArea(
          child: BlocProvider(
            create: (BuildContext context) => LoginCubit(),
            child: LoginWidget(fromComment, fromOnboard),
          ),
        ),
      ),
      onWillPop: () async {
        if (fromOnboard) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          }
          return false;
        }
        return true;
      },
    );
  }
}
