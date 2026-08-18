library;

int calcAge(DateTime dob) {
  final now = DateTime.now();
  var age = now.year - dob.year;
  if (DateTime(now.year, dob.month, dob.day).isAfter(now)) {
    age--;
  }
  return age;
}
