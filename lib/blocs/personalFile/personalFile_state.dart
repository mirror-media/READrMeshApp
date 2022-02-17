part of 'personalFile_cubit.dart';

abstract class PersonalFileState extends Equatable {
  const PersonalFileState();

  @override
  List<Object> get props => [];
}

class PersonalFileInitial extends PersonalFileState {}

class PersonalFileLoading extends PersonalFileState {}

class PersonalFileLoaded extends PersonalFileState {
  final Member viewMember;
  final Member currentMember;
  const PersonalFileLoaded(this.viewMember, this.currentMember);
}

class PersonalFileError extends PersonalFileState {
  final dynamic error;
  const PersonalFileError({this.error});
}
