class Interest {
  final int id;
  final String interest;

  Interest({required this.id, required this.interest});

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(id: json['id'], interest: json['interest']);
  }
}
