import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/home/recommendFollowItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class RecommendFollowBlock extends StatelessWidget {
  final List<Member> recommendedMembers;
  final Member member;
  const RecommendFollowBlock(this.recommendedMembers, this.member);

  @override
  Widget build(BuildContext context) {
    if (recommendedMembers.isEmpty) {
      return Container();
    }
    int itemLength = 5;
    if (recommendedMembers.length < 5) {
      itemLength = recommendedMembers.length;
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推薦追蹤',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  AutoRouter.of(context)
                      .push(RecommendFollowRoute(
                        recommendedMembers: recommendedMembers,
                        member: member,
                      ))
                      .whenComplete(() =>
                          context.read<HomeBloc>().add(RefreshHomeScreen()));
                },
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 20),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == 4) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _showMoreItem(context),
                );
              }
              return RecommendFollowItem(recommendedMembers[index], member);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: itemLength,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _showMoreItem(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 89,
              child: _moreProfilePhotoStack(),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 34,
              child: Text(
                '探索更多為你推薦的使用者',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  AutoRouter.of(context)
                      .push(RecommendFollowRoute(
                        recommendedMembers: recommendedMembers,
                        member: member,
                      ))
                      .whenComplete(() =>
                          context.read<HomeBloc>().add(RefreshHomeScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black87, width: 1),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  '查看全部',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreProfilePhotoStack() {
    List<Member> members = [];
    for (int i = 4; i < 7 && i < recommendedMembers.length; i++) {
      members.add(recommendedMembers[i]);
    }
    if (members.length == 1) {
      return ProfilePhotoWidget(members[0], 32);
    } else if (members.length == 2) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.topRight,
            child: ProfilePhotoWidget(members[0], 26),
          ),
          Container(
            padding: const EdgeInsets.only(left: 24),
            alignment: Alignment.bottomLeft,
            child: ProfilePhotoWidget(members[1], 26),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 29),
            alignment: Alignment.topLeft,
            child: ProfilePhotoWidget(members[0], 26),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 8, right: 14),
            alignment: Alignment.bottomRight,
            child: ProfilePhotoWidget(members[1], 26),
          ),
          Container(
            padding: const EdgeInsets.only(left: 14),
            alignment: Alignment.bottomLeft,
            child: ProfilePhotoWidget(members[2], 26),
          ),
        ],
      );
    }
  }
}
