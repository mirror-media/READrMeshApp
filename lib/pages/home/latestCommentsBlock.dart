import 'package:flutter/material.dart';
import 'package:readr/models/newsListItemList.dart';
import 'package:readr/pages/home/latestCommentItem.dart';

class LatestCommentsBlock extends StatelessWidget {
  final NewsListItemList latestCommentsNewsList;
  final String myId;
  const LatestCommentsBlock(this.latestCommentsNewsList, this.myId);

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
            return InkWell(
              onTap: () {},
              child: LatestCommentItem(
                latestCommentsNewsList[index - 1],
                myId,
              ),
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
