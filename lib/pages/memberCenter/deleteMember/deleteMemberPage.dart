import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/memberCenter/deleteMember/deleteMemberWidget.dart';

class DeleteMemberPage extends StatelessWidget {
  final Member member;
  const DeleteMemberPage({required this.member});
  @override
  Widget build(BuildContext context) {
    return DeleteMemberWidget(member: member);
  }
}
