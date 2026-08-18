class UserHasTravelstyle {
  final String userId;
  final int travelstyleId;

  UserHasTravelstyle({required this.userId, required this.travelstyleId});

  factory UserHasTravelstyle.fromJson(Map<String, dynamic> json) {
    return UserHasTravelstyle(
      userId: json['user_userId'],
      travelstyleId: json['travelstyle_travelId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_userId': userId, 'travelstyle_travelId': travelstyleId};
  }
}