import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/author/bloc.dart';
import 'package:readr/models/people.dart';
import 'package:readr/pages/author/authorWidget.dart';

class AuthorPage extends StatelessWidget {
  final People people;
  const AuthorPage({
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthorStoryListBloc(),
      child: AuthorWidget(people),
    );
  }
}
