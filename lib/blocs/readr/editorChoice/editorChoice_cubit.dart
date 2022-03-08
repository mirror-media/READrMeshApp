import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/services/editorChoiceService.dart';

part 'editorChoice_state.dart';

class EditorChoiceCubit extends Cubit<EditorChoiceState> {
  EditorChoiceCubit() : super(EditorChoiceInitial());
  final EditorChoiceServices _editorChoiceServices = EditorChoiceServices();

  fetchEditorChoice() async {
    emit(EditorChoiceLoading());
    try {
      emit(EditorChoiceLoaded(
          await _editorChoiceServices.fetchNewsListItemList()));
    } catch (e) {
      emit(EditorChoiceError(e.toString()));
    }
  }
}
