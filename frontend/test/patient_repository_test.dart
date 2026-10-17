import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saranutri/patients/patient.dart';
import 'package:saranutri/patients/patient_repository.dart';

void main() {
  const apiUrl = 'http://gemstone.example:8888';

  test('fetchAll maps persisted patients returned by GemStone', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url, Uri.parse('$apiUrl/patients'));
      return http.Response(
        jsonEncode([
          {
            'givenName': 'Ada',
            'familyName': 'Lovelace',
            'birthDate': '1815-12-10',
          },
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = HttpPatientRepository(
      baseUri: Uri.parse(apiUrl),
      client: client,
    );

    final patients = await repository.fetchAll();

    expect(patients, hasLength(1));
    expect(patients.single.displayName, 'Lovelace, Ada');
    expect(patients.single.birthDate, DateTime(1815, 12, 10));
  });

  test('add sends JSON and maps the patient committed by GemStone', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Uri.parse('$apiUrl/patients'));
      expect(request.headers['content-type'], startsWith('text/plain'));
      expect(jsonDecode(request.body), {
        'givenName': 'Ada',
        'familyName': 'Lovelace',
        'birthDate': null,
      });
      return http.Response(request.body, 201);
    });
    final repository = HttpPatientRepository(
      baseUri: Uri.parse(apiUrl),
      client: client,
    );

    final patient = await repository.add(
      const Patient(givenName: 'Ada', familyName: 'Lovelace'),
    );

    expect(patient.displayName, 'Lovelace, Ada');
  });
}
