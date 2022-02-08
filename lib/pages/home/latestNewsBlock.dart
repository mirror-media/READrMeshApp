import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/latestNewsItem.dart';
import 'package:readr/pages/home/recommendFollowBlock.dart';

class LatestNewsBlock extends StatefulWidget {
  final List<NewsListItem> allLatestNews;
  final List<Member> recommendedMembers;
  final Member member;
  const LatestNewsBlock(
      this.allLatestNews, this.recommendedMembers, this.member);

  @override
  _LatestNewsBlockState createState() => _LatestNewsBlockState();
}

class _LatestNewsBlockState extends State<LatestNewsBlock> {
  @override
  Widget build(BuildContext context) {
    if (widget.allLatestNews.isEmpty) {
      return Container();
    }
    List<NewsListItem> filteredList = [];

    // remove when filter is finished
    filteredList = widget.allLatestNews;

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
            const SizedBox(height: 12),
            _latestNewsList(context, filteredList.sublist(0, 5)),
            RecommendFollowBlock(widget.recommendedMembers, widget.member),
            _latestNewsList(context, filteredList.sublist(5)),
            Container(
              height: 16,
              color: Colors.white,
            ),
            Container(
              color: homeScreenBackgroundColor,
              height: 20,
            ),
            Container(
              alignment: Alignment.center,
              color: homeScreenBackgroundColor,
              child: RichText(
                text: const TextSpan(
                  text: '🎉 ',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '你已看完所有新聞囉',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: homeScreenBackgroundColor,
              height: 145,
            ),
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
          onTap: () {
            AutoRouter.of(context).push(NewsStoryRoute(
              news: newsList[index],
              member: widget.member,
            ));
          },
          child: LatestNewsItem(
            newsList[index],
            widget.member,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 20),
          child: Divider(
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: newsList.length,
    );
  }
}
