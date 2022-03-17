import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/publisher/publisher_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/publisher/publisherWidget.dart';

class PublisherPage extends StatelessWidget {
  final Publisher publisher;
  const PublisherPage(this.publisher);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        centerTitle: Platform.isIOS,
        backgroundColor: Colors.white,
        title: Text(
          publisher.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocProvider(
          create: (context) => PublisherCubit(),
          child: PublisherWidget(publisher),
        ),
      ),
    );
  }
}
