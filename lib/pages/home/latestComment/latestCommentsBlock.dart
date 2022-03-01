import 'package:flutter/material.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/latestComment/latestCommentItem.dart';

class LatestCommentsBlock extends StatelessWidget {
  final List<NewsListItem> latestCommentsNewsList;
  final List<MemberFollowableItem> recommendedMembers;
  const LatestCommentsBlock(
    this.latestCommentsNewsList,
    this.recommendedMembers,
  );

  @override
  Widget build(BuildContext context) {
    if (latestCommentsNewsList.isEmpty) {
      return Container();
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: Colors.white,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Text(
                '最新留言',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
            int recommendedIndex = recommendedMembers.indexWhere((element) =>
                element.member.memberId ==
                latestCommentsNewsList[index - 1].showComment!.member.memberId);

            return LatestCommentItem(
              latestCommentsNewsList[index - 1],
              recommendedIndex != -1
                  ? recommendedMembers[recommendedIndex].isFollowed
                  : false,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 20,
          ),
          itemCount: latestCommentsNewsList.length + 1,
        ),
      ),
    );
  }
}
