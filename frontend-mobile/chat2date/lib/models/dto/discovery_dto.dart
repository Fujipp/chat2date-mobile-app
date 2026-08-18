class DiscoveryResponse {
  final String userId;
  final String nickname;
  final int age;
  final String sex;
  final List<String> photos;
  final List<String> tags;
  final List<String> travelStyles;
  final List<String> interests;
  final List<String> lifestyles;
  final double distance;
  final int compatibilityScore;

  DiscoveryResponse({
    required this.userId,
    required this.nickname,
    required this.age,
    required this.sex,
    required this.photos,
    required this.tags,
    required this.travelStyles,
    required this.interests,
    required this.lifestyles,
    required this.distance,
    required this.compatibilityScore,
  });

  factory DiscoveryResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryResponse(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      travelStyles:
          (json['travelStyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lifestyles:
          (json['lifestyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      distance: (json['distance'] as num).toDouble(),
      compatibilityScore: json['compatibilityScore'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'age': age,
      'sex': sex,
      'photos': photos,
      'tags': tags,
      'travelStyles': travelStyles,
      'interests': interests,
      'lifestyles': lifestyles,
      'distance': distance,
      'compatibilityScore': compatibilityScore,
    };
  }

  DiscoveryResponse copyWith({
    String? userId,
    String? nickname,
    int? age,
    String? sex,
    List<String>? photos,
    List<String>? tags,
    List<String>? travelStyles,
    List<String>? interests,
    List<String>? lifestyles,
    double? distance,
    int? compatibilityScore,
  }) {
    return DiscoveryResponse(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      travelStyles: travelStyles ?? this.travelStyles,
      interests: interests ?? this.interests,
      lifestyles: lifestyles ?? this.lifestyles,
      distance: distance ?? this.distance,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
    );
  }
}
