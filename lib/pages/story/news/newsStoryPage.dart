import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/news/newsStoryWidget.dart';
import 'package:readr/pages/story/news/newsWebviewWidget.dart';

class NewsStoryPage extends StatelessWidget {
  final NewsListItem news;
  final Member member;

  const NewsStoryPage({
    required this.news,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocProvider(
          create: (context) => NewsCubit(),
          child: news.fullContent
              ? NewsStoryWidget(
                  news: news,
                  member: member,
                )
              : NewsWebviewWidget(
                  news: news,
                  member: member,
                ),
        ));
  }
}
