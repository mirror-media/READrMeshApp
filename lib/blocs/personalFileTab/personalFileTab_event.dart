part of 'personalFileTab_bloc.dart';

abstract class PersonalFileTabEvent extends Equatable {
  const PersonalFileTabEvent();

  @override
  List<Object> get props => [];
}

class FetchTabContent extends PersonalFileTabEvent {
  final Member viewMember;
  final Member currentMember;
  final TabContentType tabContentType;
  const FetchTabContent({
    required this.viewMember,
    required this.currentMember,
    required this.tabContentType,
  });

  @override
  String toString() => 'Fetch tab content';
}

class LoadMore extends PersonalFileTabEvent {
  final DateTime lastPickTime;
  const LoadMore({required this.lastPickTime});

  @override
  String toString() => 'Loading more tab contnet';
}

class ReloadTab extends PersonalFileTabEvent {
  const ReloadTab();

  @override
  String toString() => 'ReloadTab';
}
