import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0.5,
      title: SvgPicture.asset(
        appBarIconSvg,
      ),
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(
        //     Icons.notifications_none_outlined,
        //     color: readrBlack,
        //   ),
        // )
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () {
                AutoRouter.of(context).push(const CheckInvitationCodeRoute());
              },
              icon: SvgPicture.asset(
                UserHelper.instance.hasInvitationCode
                    ? newInvitationCodeSvg
                    : invitationCodeSvg,
                fit: BoxFit.cover,
              ),
            );
          },
        )
      ],
    );
  }
}
