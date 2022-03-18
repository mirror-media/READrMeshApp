part of 'pickButton_cubit.dart';

abstract class PickButtonState extends Equatable {
  const PickButtonState();

  @override
  List<Object> get props => [];
}

class PickButtonInitial extends PickButtonState {}

class PickButtonUpdating extends PickButtonState {
  final Comment? comment;
  const PickButtonUpdating({this.comment});
}

class PickButtonUpdateFailed extends PickButtonState {
  final bool originIsPicked;
  const PickButtonUpdateFailed(this.originIsPicked);
}

class PickButtonUpdateSuccess extends PickButtonState {
  final Comment? comment;
  final bool isPicked;
  const PickButtonUpdateSuccess(this.isPicked, {this.comment});
}

class RemovePickAndComment extends PickButtonState {
  final String commentId;
  final String targetId;
  final PickObjective objective;
  const RemovePickAndComment(this.commentId, this.targetId, this.objective);
}
