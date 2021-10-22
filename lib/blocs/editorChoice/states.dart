import 'package:equatable/equatable.dart';
import 'package:readr/models/editorChoiceItem.dart';

enum EditorChoiceStatus {
  initial,
  loading,
  loaded,
  error,
}

class EditorChoiceState extends Equatable {
  final EditorChoiceStatus status;
  final List<EditorChoiceItem> editorChoiceList;
  final dynamic error;
  const EditorChoiceState._({
    required this.status,
    this.editorChoiceList = const [],
    this.error = '',
  });

  const EditorChoiceState.initial()
      : this._(status: EditorChoiceStatus.initial);

  const EditorChoiceState.loading()
      : this._(status: EditorChoiceStatus.loading);

  const EditorChoiceState.loaded(List<EditorChoiceItem> editorChoiceList)
      : this._(
          status: EditorChoiceStatus.loaded,
          editorChoiceList: editorChoiceList,
        );

  const EditorChoiceState.error(dynamic error)
      : this._(status: EditorChoiceStatus.error, error: error);

  @override
  List<Object> get props => [status, editorChoiceList];
}
