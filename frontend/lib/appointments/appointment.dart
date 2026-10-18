import 'package:saranutri/patients/patient.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.patient,
    required this.scheduledAt,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
      status: json['status'] as String,
    );
  }

  final String id;
  final Patient patient;
  final DateTime scheduledAt;
  final String status;
}
