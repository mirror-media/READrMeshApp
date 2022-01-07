class Member {
  final String email;
  final String firebaseId;
  final String memberId;
  final String nickname;
  final String name;
  Member({
    required this.firebaseId,
    required this.memberId,
    required this.nickname,
    required this.email,
    required this.name,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['id'],
      firebaseId: json['firebaseId'],
      email: json['email'],
      nickname: json['nickname'],
      name: json['name'],
    );
  }
}
