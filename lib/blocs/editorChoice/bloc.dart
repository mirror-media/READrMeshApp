import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/editorChoice/events.dart';
import 'package:readr/blocs/editorChoice/states.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/services/editorChoiceService.dart';

class EditorChoiceBloc extends Bloc<EditorChoiceEvents, EditorChoiceState> {
  final EditorChoiceRepos editorChoiceRepos;
  List<EditorChoiceItem> editorChoiceList = [];

  EditorChoiceBloc({required this.editorChoiceRepos})
      : super(const EditorChoiceState.loading());

  @override
  Stream<EditorChoiceState> mapEventToState(EditorChoiceEvents event) async* {
    yield const EditorChoiceState.loading();
    try {
      editorChoiceList = await editorChoiceRepos.fetchEditorChoiceList();
      yield EditorChoiceState.loaded(editorChoiceList);
    } on SocketException {
      yield EditorChoiceState.error(NoInternetException('No Internet'));
    } on HttpException {
      yield EditorChoiceState.error(
          NoServiceFoundException('No Service Found'));
    } on FormatException {
      yield EditorChoiceState.error(
          InvalidFormatException('Invalid Response format'));
    } catch (e) {
      yield EditorChoiceState.error(UnknownException(e.toString()));
    }
  }
}
