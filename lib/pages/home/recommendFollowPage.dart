import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/home/recommendFollowItem.dart';

class RecommendFollowPage extends StatelessWidget {
  final List<Member> recommendedMembers;
  final Member member;
  const RecommendFollowPage(this.recommendedMembers, this.member);

  @override
  Widget build(BuildContext context) {
    int itemLength = recommendedMembers.length;
    if (itemLength > 20) itemLength = 20;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '推薦追蹤',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) =>
                RecommendFollowItem(recommendedMembers[index], member),
            itemCount: itemLength,
          ),
        ),
      ),
    );
  }
}
