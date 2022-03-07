part of 'chooseFollow_cubit.dart';

abstract class ChooseFollowState extends Equatable {
  const ChooseFollowState();

  @override
  List<Object> get props => [];
}

class ChooseFollowInitial extends ChooseFollowState {}

class ChooseFollowLoading extends ChooseFollowState {}

class PublisherListLoaded extends ChooseFollowState {
  final List<Publisher> allPublisher;
  const PublisherListLoaded(this.allPublisher);
}

class MemberListLoaded extends ChooseFollowState {
  final List<Member> recommendedMembers;
  const MemberListLoaded(this.recommendedMembers);
}

class ChooseFollowError extends ChooseFollowState {
  final dynamic error;
  const ChooseFollowError(this.error);
}
