import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/tag/bloc.dart';
import 'package:readr/models/tag.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/tag/tagWidget.dart';

class TagPage extends StatefulWidget {
  final Tag tag;
  const TagPage({
    required this.tag,
  });

  @override
  _TagPageState createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late Tag _tag;

  @override
  void initState() {
    _tag = widget.tag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBar(context),
        body: BlocProvider(
            create: (context) => TagStoryListBloc(),
            child: Container(
              color: const Color.fromRGBO(246, 246, 251, 1),
              child: TagWidget(_tag),
            )));
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shadowColor: Colors.white70,
      leading: IconButton(
        icon: Icon(
          Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
          color: Colors.black,
        ),
        padding: EdgeInsets.only(
            top: 8, left: 8, bottom: 8, right: Platform.isIOS ? 12 : 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      centerTitle: Platform.isIOS,
      title: Text(
        _tag.name,
        style: const TextStyle(color: Colors.black87, fontSize: 20),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
