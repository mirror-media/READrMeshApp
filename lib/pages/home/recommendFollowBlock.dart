import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/home/recommendFollowItem.dart';

class RecommendFollowBlock extends StatelessWidget {
  final List<Member> recommendedMembers;
  final Member member;
  const RecommendFollowBlock(this.recommendedMembers, this.member);

  @override
  Widget build(BuildContext context) {
    if (recommendedMembers.isEmpty) {
      return Container();
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
                onPressed: () {},
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
        const SizedBox(height: 20),
        SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 20),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) =>
                RecommendFollowItem(recommendedMembers[index], member),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: recommendedMembers.length,
          ),
        ),
        const SizedBox(height: 44),
      ],
    );
  }
}
