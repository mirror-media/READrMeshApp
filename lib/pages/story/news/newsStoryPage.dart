import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/news/news_bloc.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/news/newsWebviewWidget.dart';

class NewsStoryPage extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  final bool isBookmarked;
  final bool isNative;

  const NewsStoryPage({
    required this.news,
    required this.member,
    required this.isBookmarked,
    this.isNative = false,
  });

  @override
  _NewsStoryPageState createState() => _NewsStoryPageState();
}

class _NewsStoryPageState extends State<NewsStoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocProvider(
          create: (context) => NewsBloc(),
          child: NewsWebviewWidget(
            news: widget.news,
            member: widget.member,
            isBookmarked: widget.isBookmarked,
          ),
        ));
  }
}
