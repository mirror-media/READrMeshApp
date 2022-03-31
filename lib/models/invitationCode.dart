import 'package:readr/models/member.dart';

class InvitationCode {
  final String code;
  final Member? activeMember;

  InvitationCode({
    required this.code,
    this.activeMember,
  });
}
