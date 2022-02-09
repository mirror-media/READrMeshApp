import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/latestNewsItem.dart';
import 'package:readr/pages/home/recommendFollowBlock.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LatestNewsBlock extends StatefulWidget {
  final List<NewsListItem> allLatestNews;
  final List<Member> recommendedMembers;
  final Member member;
  final bool showPaywall;
  final bool showFullScreenAd;
  final bool noMore;
  const LatestNewsBlock({
    required this.allLatestNews,
    required this.recommendedMembers,
    required this.member,
    this.showFullScreenAd = true,
    this.showPaywall = true,
    this.noMore = false,
  });

  @override
  _LatestNewsBlockState createState() => _LatestNewsBlockState();
}

class _LatestNewsBlockState extends State<LatestNewsBlock> {
  bool _isLoadingMore = false;
  @override
  Widget build(BuildContext context) {
    if (widget.allLatestNews.isEmpty) {
      return Container();
    }
    List<NewsListItem> filteredList = [];

    if (widget.showFullScreenAd && widget.showPaywall) {
      filteredList = widget.allLatestNews;
    } else {
      for (int i = 0; i < widget.allLatestNews.length; i++) {
        // add item that equal filter
        bool hasFullScreenAd = widget.allLatestNews[i].fullScreenAd;
        bool hasPaywall = widget.allLatestNews[i].payWall;
        bool check1 = false;
        bool check2 = false;

        if (widget.showFullScreenAd) {
          check1 = true;
        } else if (!hasFullScreenAd) {
          check1 = true;
        }

        if (widget.showPaywall) {
          check2 = true;
        } else if (!hasPaywall) {
          check2 = true;
        }

        if (check1 && check2) {
          filteredList.add(widget.allLatestNews[i]);
        }
      }
    }

    if (filteredList.isEmpty) {
      return Container();
    }

    _isLoadingMore = false;

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
            _bottomWidget(),
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

  Widget _bottomWidget() {
    if (widget.noMore) {
      return Column(
        children: [
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
      );
    } else {
      return VisibilityDetector(
        key: const Key('latestNewsBottomWidget'),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage > 70 && !_isLoadingMore) {
            context.read<HomeBloc>().add(LoadMoreLatestNews(
                widget.member, widget.allLatestNews.last.publishedDate));
            _isLoadingMore = true;
          }
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
