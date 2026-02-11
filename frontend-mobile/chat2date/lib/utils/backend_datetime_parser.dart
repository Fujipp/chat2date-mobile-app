DateTime? parseBackendDateTime(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final parsedTime = DateTime.tryParse(raw);
  if (parsedTime == null) {
    return null;
  }

  final hasTimezone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  if (hasTimezone) {
    return parsedTime.isUtc ? parsedTime.toLocal() : parsedTime;
  }

  // Backend often returns LocalDateTime without timezone marker.
  // Keep behavior consistent with chat message parsing.
  return parsedTime.add(const Duration(hours: 7));
}
