part of 'pickButton_cubit.dart';

abstract class PickButtonState extends Equatable {
  const PickButtonState();

  @override
  List<Object> get props => [];
}

class PickButtonInitial extends PickButtonState {}

class PickButtonUpdating extends PickButtonState {
  final String type;
  final String targetId;
  final bool isPicked;
  final Comment? pickComment;
  final int pickCount;
  const PickButtonUpdating({
    required this.type,
    required this.targetId,
    required this.isPicked,
    required this.pickCount,
    this.pickComment,
  });
}

class PickButtonUpdateSuccess extends PickButtonState {
  final String type;
  final String targetId;
  final String? pickId;
  final String? commentId;
  final int pickCount;
  const PickButtonUpdateSuccess({
    required this.type,
    required this.targetId,
    required this.pickId,
    required this.pickCount,
    this.commentId,
  });
}

class PickButtonUpdateFailed extends PickButtonState {
  final dynamic error;
  final bool originIsPicked;
  final String type;
  final String targetId;
  final String? pickId;
  final String? commentId;
  final int pickCount;
  const PickButtonUpdateFailed({
    required this.type,
    required this.targetId,
    required this.pickId,
    required this.pickCount,
    this.commentId,
    this.error,
    required this.originIsPicked,
  });
}
