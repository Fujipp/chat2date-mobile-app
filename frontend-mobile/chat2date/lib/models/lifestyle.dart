class Lifestyle {
  final int id;
  final String lifestyle;

  Lifestyle({required this.id, required this.lifestyle});

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(id: json['id'], lifestyle: json['lifeStyle']);
  }
}
