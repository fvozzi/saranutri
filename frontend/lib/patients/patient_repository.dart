import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:saranutri/patients/patient.dart';

abstract interface class PatientRepository {
  Future<List<Patient>> fetchAll();

  Future<Patient> add(Patient patient);
}

class HttpPatientRepository implements PatientRepository {
  HttpPatientRepository({required Uri baseUri, required http.Client client})
      : _patientsUri = _buildPatientsUri(baseUri),
        _client = client;

  final Uri _patientsUri;
  final http.Client _client;

  @override
  Future<List<Patient>> fetchAll() async {
    final response = await _client.get(
      _patientsUri,
      headers: const {'accept': 'application/json'},
    );
    _requireStatus(response, 200);
    final payload = _decodeJson(response);
    if (payload is! List<dynamic>) {
      throw const PatientRepositoryException();
    }
    return payload
        .map((entry) => Patient.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Patient> add(Patient patient) async {
    final response = await _client.post(
      _patientsUri,
      headers: const {
        'accept': 'application/json',
        // A simple content type avoids an unnecessary browser CORS preflight.
        'content-type': 'text/plain; charset=UTF-8',
      },
      body: jsonEncode(patient.toJson()),
      encoding: utf8,
    );
    _requireStatus(response, 201);
    return Patient.fromJson(_decodeJson(response) as Map<String, dynamic>);
  }

  static Uri _buildPatientsUri(Uri baseUri) {
    final base = baseUri.toString().replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$base/patients');
  }

  static Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const PatientRepositoryException();
    }
  }

  static void _requireStatus(http.Response response, int expectedStatus) {
    if (response.statusCode != expectedStatus) {
      throw const PatientRepositoryException();
    }
  }
}

class PatientRepositoryException implements Exception {
  const PatientRepositoryException();
}
