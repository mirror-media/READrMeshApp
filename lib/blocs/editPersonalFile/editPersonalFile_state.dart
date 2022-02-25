part of 'editPersonalFile_cubit.dart';

abstract class EditPersonalFileState extends Equatable {
  const EditPersonalFileState();

  @override
  List<Object> get props => [];
}

class EditPersonalFileInitial extends EditPersonalFileState {}

class EditPersonalFileLoading extends EditPersonalFileState {}

class EditPersonalFileLoaded extends EditPersonalFileState {}

class EditPersonalFileError extends EditPersonalFileState {
  final dynamic error;
  const EditPersonalFileError(this.error);
}

class PersonalFileSaving extends EditPersonalFileState {}

class PersonalFileSaved extends EditPersonalFileState {}

class PersonalFileIdError extends EditPersonalFileState {}

class PersonalFileNicknameError extends EditPersonalFileState {}

class SavePersonalFileFailed extends EditPersonalFileState {}
