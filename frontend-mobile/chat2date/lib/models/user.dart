enum Provider { GOOGLE, OTP }

enum Sex { MALE, FEMALE }

enum AccountStatus { ACTIVE, SUSPENDED, PENDING }

enum Role { USER, ADMIN }

class User {
  final String userId;
  final String? email;
  final String? phoneNumber;
  final Provider? provider;
  final String? firstname;
  final String? lastname;
  final String? nickname;
  final String? cardId;
  final DateTime? birthday;
  final Sex? sex;
  final int? behaviorScore;
  final bool? isBlacklist;
  final AccountStatus? accountStatus;
  final int? version;
  final Role? role;

  const User({
    this.accountStatus,
    required this.userId,
    this.behaviorScore,
    this.birthday,
    this.cardId,
    this.email,
    this.firstname,
    this.isBlacklist,
    this.lastname,
    this.nickname,
    this.phoneNumber,
    this.provider,
    this.role,
    this.sex,
    this.version,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) =>
        dateStr != null ? DateTime.parse(dateStr) : null;

    T? enumFromString<T>(List<T> values, String? key) {
      if (key == null) return null;
      return values.firstWhere(
        (e) => e.toString().split('.').last == key,
        orElse: () => values.first,
      );
    }

    return User(
      userId: json['userId'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      provider: enumFromString(Provider.values, json['provider']),
      firstname: json['firstname'],
      lastname: json['lastname'],
      nickname: json['nickname'],
      cardId: json['cardId'],
      birthday: parseDate(json['birthday']),
      sex: enumFromString(Sex.values, json['sex']),
      behaviorScore: json['behaviorScore'],
      isBlacklist: json['isBlacklist'],
      accountStatus: enumFromString(
        AccountStatus.values,
        json['accountStatus'],
      ),
      version: json['version'],
      role: enumFromString(Role.values, json['role']),
    );
  }

  // toJson
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'phoneNumber': phoneNumber,
    'provider': provider?.toString().split('.').last,
    'firstname': firstname,
    'lastname': lastname,
    'nickname': nickname,
    'cardId': cardId,
    'birthday': birthday?.toIso8601String(),
    'sex': sex?.toString().split('.').last,
    'behaviorScore': behaviorScore,
    'isBlacklist': isBlacklist,
    'accountStatus': accountStatus?.toString().split('.').last,
    'version': version,
    'role': role?.toString().split('.').last,
  };
}
