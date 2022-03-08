import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/newsStoryWidget.dart';
import 'package:readr/pages/story/newsWebviewWidget.dart';

class NewsStoryPage extends StatelessWidget {
  final NewsListItem news;

  const NewsStoryPage({
    required this.news,
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
                )
              : NewsWebviewWidget(
                  news: news,
                ),
        ));
  }
}
