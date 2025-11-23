class UserHasLifestyle {
  final String userId;
  final int lifestyleId;

  UserHasLifestyle({required this.userId, required this.lifestyleId});

  factory UserHasLifestyle.fromJson(Map<String, dynamic> json) {
    return UserHasLifestyle(
      userId: json['user_userId'],
      lifestyleId: json['lifestyle_lifestyleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_userId': userId, 'lifestyle_lifestyleId': lifestyleId};
  }
}
