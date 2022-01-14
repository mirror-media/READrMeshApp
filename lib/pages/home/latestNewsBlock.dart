import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsListItemList.dart';
import 'package:readr/pages/home/latestNewsItem.dart';
import 'package:readr/pages/home/recommendFollowBlock.dart';

class LatestNewsBlock extends StatefulWidget {
  final NewsListItemList otherNewsList;
  final List<Member> recommendedMembers;
  final Member? member;
  const LatestNewsBlock(
      this.otherNewsList, this.recommendedMembers, this.member);

  @override
  _LatestNewsBlockState createState() => _LatestNewsBlockState();
}

class _LatestNewsBlockState extends State<LatestNewsBlock> {
  @override
  Widget build(BuildContext context) {
    if (widget.otherNewsList.isEmpty) {
      return Container();
    }
    NewsListItemList filteredList = NewsListItemList();

    // remove when filter is finished
    filteredList = widget.otherNewsList;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '最新文章',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list_outlined,
                      color: Colors.black54,
                      size: 22,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 22.5),
            _latestNewsList(context, filteredList.sublist(0, 5)),
            RecommendFollowBlock(
                widget.recommendedMembers, widget.member?.memberId ?? ""),
            _latestNewsList(context, filteredList.sublist(5))
          ],
        ),
      ),
    );
  }

  Widget _latestNewsList(BuildContext context, List<NewsListItem> newsList) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: LatestNewsItem(
            newsList[index],
            widget.member,
          ),
        );
      },
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(top: 16, bottom: 20),
        child: Divider(
          color: Colors.black12,
          thickness: 1,
          height: 1,
        ),
      ),
      itemCount: newsList.length,
    );
  }
}
