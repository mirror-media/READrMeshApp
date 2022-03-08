part of 'editorChoice_cubit.dart';

abstract class EditorChoiceState extends Equatable {
  const EditorChoiceState();

  @override
  List<Object> get props => [];
}

class EditorChoiceInitial extends EditorChoiceState {}

class EditorChoiceLoading extends EditorChoiceState {}

class EditorChoiceLoaded extends EditorChoiceState {
  final List<EditorChoiceItem> editorChoiceList;
  const EditorChoiceLoaded(this.editorChoiceList);
}

class EditorChoiceError extends EditorChoiceState {
  final String error;
  const EditorChoiceError(this.error);
}
