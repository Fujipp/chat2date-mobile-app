enum Provider { google, otp }

enum Sex { male, female }

enum AccountStatus { active, suspended, pending }

enum Role { user, admin }

class User {
  final String userId;
  final String? email;
  final String? phoneNumber;
  final bool? isVerify;
  final Provider? provider;
  final String? firstname;
  final String? lastname;
  final String? cardId;
  final DateTime? birthday;
  final int? age;
  final Sex? sex;
  final bool? faceVerify;
  final int? behaviorScore;
  final bool? isBlacklist;
  final AccountStatus? accountStatus;
  final int? version;
  final Role? role;

  const User({
    this.accountStatus,
    this.age,
    required this.userId,
    this.behaviorScore,
    this.birthday,
    this.cardId,
    this.email,
    this.faceVerify,
    this.firstname,
    this.isBlacklist,
    this.isVerify,
    this.lastname,
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
      isVerify: json['isVerify'],
      provider: enumFromString(Provider.values, json['provider']),
      firstname: json['firstname'],
      lastname: json['lastname'],
      cardId: json['cardId'],
      birthday: parseDate(json['birthday']),
      age: json['age'],
      sex: enumFromString(Sex.values, json['sex']),
      faceVerify: json['faceVerify'],
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
    'isVerify': isVerify,
    'provider': provider?.toString().split('.').last,
    'firstname': firstname,
    'lastname': lastname,
    'cardId': cardId,
    'birthday': birthday?.toIso8601String(),
    'age': age,
    'sex': sex?.toString().split('.').last,
    'faceVerify': faceVerify,
    'behaviorScore': behaviorScore,
    'isBlacklist': isBlacklist,
    'accountStatus': accountStatus?.toString().split('.').last,
    'version': version,
    'role': role?.toString().split('.').last,
  };
}
