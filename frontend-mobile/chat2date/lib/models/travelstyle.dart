class Travelstyle {
  final int id;
  final String travelstyle;

  Travelstyle({required this.id, required this.travelstyle});

  factory Travelstyle.fromJson(Map<String, dynamic> json) {
    return Travelstyle(id: json['id'], travelstyle: json['travelStyle']);
  }
}
