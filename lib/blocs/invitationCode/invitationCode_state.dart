part of 'invitationCode_cubit.dart';

abstract class InvitationCodeState extends Equatable {
  const InvitationCodeState();

  @override
  List<Object> get props => [];
}

class InvitationCodeInitial extends InvitationCodeState {}

class InvitationCodeLoading extends InvitationCodeState {}

class InvitationCodeLoaded extends InvitationCodeState {
  final List<InvitationCode> usableCodeList;
  final List<InvitationCode> activatedCodeList;
  const InvitationCodeLoaded({
    required this.usableCodeList,
    required this.activatedCodeList,
  });
}

class InvitationCodeError extends InvitationCodeState {
  final dynamic error;
  const InvitationCodeError(this.error);
}
