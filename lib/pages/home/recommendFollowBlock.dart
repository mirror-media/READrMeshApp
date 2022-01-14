import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/home/recommendFollowItem.dart';

class RecommendFollowBlock extends StatelessWidget {
  final List<Member> recommendedMembers;
  final String myId;
  const RecommendFollowBlock(this.recommendedMembers, this.myId);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
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
        const SizedBox(height: 20),
        ListView.separated(
          padding: const EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) =>
              RecommendFollowItem(recommendedMembers[index], myId),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: recommendedMembers.length,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
