import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saranutri/appointments/appointment_repository.dart';

void main() {
  const apiUrl = 'http://gemstone.example:8888';
  final payload = {
    'id': 'appointment-1',
    'patient': {
      'id': 'patient-1',
      'givenName': 'Ada',
      'familyName': 'Lovelace',
      'birthDate': null,
    },
    'scheduledAt': '2026-11-02T13:30:00.000Z',
    'status': 'scheduled',
  };

  test('fetchAll sends the session and maps appointments', () async {
    final repository = HttpAppointmentRepository(
      baseUri: Uri.parse(apiUrl),
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['authorization'], 'Bearer token-123');
        return http.Response(jsonEncode([payload]), 200);
      }),
    );

    final appointments = await repository.fetchAll('token-123');

    expect(appointments.single.id, 'appointment-1');
    expect(appointments.single.patient.displayName, 'Lovelace, Ada');
  });

  test('add sends patient and UTC schedule', () async {
    final repository = HttpAppointmentRepository(
      baseUri: Uri.parse(apiUrl),
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['authorization'], 'Bearer token-123');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['patientId'], 'patient-1');
        expect(body['scheduledAt'], endsWith('Z'));
        return http.Response(jsonEncode(payload), 201);
      }),
    );

    final appointment = await repository.add(
      accessToken: 'token-123',
      patientId: 'patient-1',
      scheduledAt: DateTime(2026, 11, 2, 10, 30),
    );

    expect(appointment.id, 'appointment-1');
  });
}
