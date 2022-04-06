import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/services/editorChoiceService.dart';

part 'editorChoice_state.dart';

class EditorChoiceCubit extends Cubit<EditorChoiceState> {
  final EditorChoiceRepos editorChoiceRepo;
  EditorChoiceCubit({required this.editorChoiceRepo})
      : super(EditorChoiceInitial());

  fetchEditorChoice() async {
    emit(EditorChoiceLoading());
    try {
      emit(EditorChoiceLoaded(await editorChoiceRepo.fetchNewsListItemList()));
    } catch (e) {
      emit(EditorChoiceError(e.toString()));
    }
  }
}
