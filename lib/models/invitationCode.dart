import 'package:readr/models/member.dart';

class InvitationCode {
  final String code;
  final Member? activeMember;

  InvitationCode({
    required this.code,
    this.activeMember,
  });

  factory InvitationCode.fromJson(Map<String, dynamic> json) {
    Member? activeMember;
    if (json['receive'] != null) {
      activeMember = Member.fromJson(json['receive']);
    }
    return InvitationCode(
      code: json['code'],
      activeMember: activeMember,
    );
  }
}
