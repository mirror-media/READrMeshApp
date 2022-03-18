import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/newsStoryWidget.dart';
import 'package:readr/pages/story/newsWebviewWidget.dart';
import 'package:readr/pages/story/readrStoryWidget.dart';

class NewsStoryPage extends StatelessWidget {
  final NewsListItem news;

  const NewsStoryPage({
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!news.fullContent) {
      child = NewsWebviewWidget(
        news: news,
      );
    } else if (news.source?.title == 'readr') {
      child = ReadrStoryWidget(
        news: news,
      );
    } else {
      child = NewsStoryWidget(
        news: news,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => NewsCubit(),
          ),
          BlocProvider(
            create: (context) =>
                CommentBloc(BlocProvider.of<PickButtonCubit>(context)),
          ),
        ],
        child: child,
      ),
    );
  }
}
