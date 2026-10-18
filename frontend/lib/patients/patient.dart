class Patient {
  const Patient({
    required this.id,
    required this.givenName,
    required this.familyName,
    this.birthDate,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      givenName: json['givenName'] as String,
      familyName: json['familyName'] as String,
      birthDate: _dateFromJson(json['birthDate']),
    );
  }

  final String id;
  final String givenName;
  final String familyName;
  final DateTime? birthDate;

  String get displayName => '$familyName, $givenName';

  String get initials => '${givenName[0]}${familyName[0]}'.toUpperCase();

  Map<String, dynamic> toJson() {
    return {
      'givenName': givenName,
      'familyName': familyName,
      'birthDate': _dateToJson(birthDate),
    };
  }

  static DateTime? _dateFromJson(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }

  static String? _dateToJson(DateTime? value) {
    if (value == null) {
      return null;
    }
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
