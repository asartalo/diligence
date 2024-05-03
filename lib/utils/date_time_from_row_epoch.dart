DateTime dateTimeFromRowEpoch(dynamic epochData) {
  return DateTime.fromMillisecondsSinceEpoch(epochData as int);
}
