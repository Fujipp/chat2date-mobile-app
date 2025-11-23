class UserHasInterest {
  final String userId;
  final int interestId;

  UserHasInterest({required this.userId, required this.interestId});

  factory UserHasInterest.fromJson(Map<String, dynamic> json) {
    return UserHasInterest(
      userId: json['user_userId'],
      interestId: json['interest_interestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_userId': userId, 'interest_interestId': interestId};
  }
}
