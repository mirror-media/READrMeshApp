part of 'pickButton_cubit.dart';

abstract class PickButtonState extends Equatable {
  const PickButtonState();

  @override
  List<Object> get props => [];
}

class PickButtonInitial extends PickButtonState {}

class PickButtonUpdating extends PickButtonState {
  final Comment? comment;
  final PickableItem item;
  const PickButtonUpdating(this.item, {this.comment});
}

class PickButtonUpdateFailed extends PickButtonState {
  final bool originIsPicked;
  final PickableItem item;
  const PickButtonUpdateFailed(this.item, this.originIsPicked);
}

class PickButtonUpdateSuccess extends PickButtonState {
  final Comment? comment;
  final bool isPicked;
  final PickableItem item;
  const PickButtonUpdateSuccess(this.isPicked, this.item, {this.comment});
}

class RemovePickAndComment extends PickButtonState {
  final String commentId;
  final PickableItem item;
  const RemovePickAndComment(this.commentId, this.item);
}

class AddPickCommentFailed extends PickButtonState {
  final PickableItem item;
  const AddPickCommentFailed(this.item);
}

class RemovePickAndCommentFailed extends PickButtonState {
  final PickableItem item;
  const RemovePickAndCommentFailed(this.item);
}
