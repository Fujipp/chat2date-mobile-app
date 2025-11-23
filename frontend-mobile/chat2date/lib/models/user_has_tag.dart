class UserHasTag {
  final String userId;
  final int tagId;

  UserHasTag({required this.userId, required this.tagId});

  factory UserHasTag.fromJson(Map<String, dynamic> json) {
    return UserHasTag(
      userId: json['user_userId'],
      tagId: json['tag_tagId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_userId': userId, 'tag_tagId': tagId};
  }
}