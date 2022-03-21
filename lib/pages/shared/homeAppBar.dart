import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readr/helpers/dataConstants.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0.5,
      title: const Text(
        'Logo',
        style: TextStyle(
          color: readrBlack,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: readrBlack,
          ),
        )
      ],
    );
  }
}
