class Member {
  final String? email;
  final String firebaseId;
  final String memberId;
  final String? nickname;
  Member({
    required this.firebaseId,
    required this.memberId,
    this.nickname,
    this.email,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['id'],
      firebaseId: json['firebaseId'],
      email: json['email'],
      nickname: json['nickname'],
    );
  }
}
